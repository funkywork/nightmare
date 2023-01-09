(*  MIT License

    Copyright (c) 2023 funkywork

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE. *)

open Nightmare_test
open Nightmare_service
module R = Dummy_request

module Routes = struct
  open Endpoint
  open Path

  let hello_world () = get (~/"hello" / "world")
  let sum () = post (~/"sum" / "a" /: int / "b" /: int)
  let cheap_auth () = post (~/"auth" /: string /: string)
  let provided_page () = post ~/"provided"
  let cheap_failable_auth () = post (~/"auth-failable" /: string /: string)
  let binop () = post (~/"binop" /: char / "a" /: int / "b" /: int)
  let provided_auth () = post ~/"provided-auth"
end

module Services = struct
  let hello_world =
    Service.straight ~endpoint:Routes.hello_world (fun request ->
      Lwt.return @@ R.ok "Hello, World!" request)
  ;;

  let sum =
    Service.straight ~endpoint:Routes.sum (fun a b request ->
      Lwt.return @@ R.ok (string_of_int (a + b)) request)
  ;;

  let binop =
    Service.failable
      ~endpoint:Routes.binop
      ~ok:(fun result request ->
        Lwt.return @@ R.ok (string_of_int result) request)
      ~error:(fun (`Unknown_operator chr) request ->
        Lwt.return @@ R.error ("unknown operator " ^ String.make 1 chr) request)
      (fun char a b _request ->
        Lwt.return
          (match char with
           | '+' -> Ok (a + b)
           | '-' -> Ok (a - b)
           | '*' -> Ok (a * b)
           | '/' -> Ok Stdlib.(a / b)
           | _ -> Error (`Unknown_operator char)))
  ;;

  let cheap_auth =
    Service.straight
      ~middlewares:
        [ (fun inner_handler request ->
            match R.get_var ~key:"allow-auth" request with
            | None -> inner_handler @@ R.redirect "https://public.com" request
            | Some _ -> inner_handler @@ R.ok "can be connected" request)
        ]
      ~endpoint:Routes.cheap_auth
      (fun login password request ->
        match R.status_of request with
        | R.Error _ | R.Redirect _ -> Lwt.return request
        | Ok _ ->
          Lwt.return
          @@ (match R.get_var ~key:login request with
              | None -> R.error "unknown user"
              | Some pwd ->
                if String.equal password pwd
                then R.redirect "https://private.com"
                else R.error "invalid password")
               request)
  ;;

  let provided_page =
    Service.straight'
      ~endpoint:Routes.provided_page
      ~middlewares:[]
      ~provider:(fun inner_handler request ->
        match R.get_var ~key:"current_user" request with
        | None -> Lwt.return @@ R.error "not connected" request
        | Some x -> inner_handler (String.equal x "active") request)
      (fun is_active request ->
        Lwt.return
        @@
        if is_active
        then R.ok "connected" request
        else R.error "not active" request)
  ;;

  let cheap_failable_auth =
    Service.failable
      ~endpoint:Routes.cheap_failable_auth
      ~ok:(fun nickname request ->
        Lwt.return @@ R.ok ("Hello " ^ nickname) request)
      ~error:(fun error request ->
        Lwt.return
        @@ R.error
             (match error with
              | `Unknown_user -> "unknown user"
              | `Invalid_password -> "invalid password")
             request)
      (fun login password request ->
        Lwt.return
          (match R.get_var ~key:login request with
           | None -> Error `Unknown_user
           | Some pwd ->
             if String.equal password pwd
             then Ok login
             else Error `Invalid_password))
  ;;

  let provided_auth =
    Service.failable'
      ~endpoint:Routes.provided_auth
      ~provider:(fun inner_handler request ->
        match R.get_var ~key:"current_user" request with
        | None -> Lwt.return @@ R.error "not connected" request
        | Some x -> inner_handler (String.equal x "active") request)
      ~ok:(fun () request -> Lwt.return @@ R.ok "welcome" request)
      ~error:(fun `Not_active request ->
        Lwt.return @@ R.error "not active" request)
      (fun is_active _request ->
        Lwt.return @@ if is_active then Ok () else Error `Not_active)
  ;;

  let error request = Lwt.return @@ R.error "no service" request
end

let services =
  Services.
    [ hello_world
    ; sum
    ; cheap_auth
    ; provided_page
    ; cheap_failable_auth
    ; binop
    ; provided_auth
    ]
;;

let test_choose_when_there_is_no_candidate_1 =
  test_equality_lwt
    ~about:"choose"
    ~desc:
      "when there is no service that match input, it should return an error 1"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`GET
        ~given_uri:"/"
        Services.error
        (R.make_ok "root")
    in
    let expected = R.make_error "no service" in
    expected, computed)
;;

let test_choose_when_there_is_no_candidate_2 =
  test_equality_lwt
    ~about:"choose"
    ~desc:
      "when there is no service that match input, it should return an error 2"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/hello/world"
        Services.error
        (R.make_ok "root")
    in
    let expected = R.make_error "no service" in
    expected, computed)
;;

let test_choose_when_there_is_no_candidate_3 =
  test_equality_lwt
    ~about:"choose"
    ~desc:
      "when there is no service that match input, it should return an error 3"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/sum/a/10/b/foo"
        Services.error
        (R.make_ok "root")
    in
    let expected = R.make_error "no service" in
    expected, computed)
;;

let test_choose_on_hello_world =
  test_equality_lwt
    ~about:"choose"
    ~desc:
      "when choose match hello_world, it should return the string Hello, World!"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`GET
        ~given_uri:"/hello/world"
        Services.error
        (R.make_ok "root")
    in
    let expected = R.make_ok "Hello, World!" in
    expected, computed)
;;

let test_choose_on_sum =
  test_equality_lwt
    ~about:"choose"
    ~desc:"when choose match sum, it should return the result of the addition"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/sum/a/12/b/3145"
        Services.error
        (R.make_ok "root")
    in
    let expected = R.make_ok "3157" in
    expected, computed)
;;

let test_choose_on_cheap_auth_when_auth_is_not_allowed =
  let env = [ "dummy-variable", "1234" ] in
  test_equality_lwt
    ~about:"choose"
    ~desc:"when choose match auth, but auth is not allowed"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/auth/pierre/pierre-s-password1234"
        Services.error
        (R.make_ok ~env "root")
    in
    let expected = R.make_redirect ~env "https://public.com" in
    expected, computed)
;;

let test_choose_on_cheap_auth_when_user_does_not_exists =
  let env =
    [ "dummy-variable", "1234"
    ; "allow-auth", "true"
    ; "pierre", "pierre-s-password1234"
    ]
  in
  test_equality_lwt
    ~about:"choose"
    ~desc:"when choose match auth, but the user does not exists"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/auth/antoine/pierre-s-password1234"
        Services.error
        (R.make_ok ~env "root")
    in
    let expected = R.make_error ~env "unknown user" in
    expected, computed)
;;

let test_choose_on_cheap_auth_when_password_does_not_match =
  let env =
    [ "dummy-variable", "1234"
    ; "allow-auth", "true"
    ; "pierre", "pierre-s-password1234"
    ]
  in
  test_equality_lwt
    ~about:"choose"
    ~desc:
      "when choose match auth, the user exists, but passwords does not match"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/auth/pierre/pierre-s-password12345"
        Services.error
        (R.make_ok ~env "root")
    in
    let expected = R.make_error ~env "invalid password" in
    expected, computed)
;;

let test_choose_on_cheap_auth_when_user_exists_and_password_match =
  let env =
    [ "dummy-variable", "1234"
    ; "allow-auth", "true"
    ; "pierre", "pierre-s-password1234"
    ]
  in
  test_equality_lwt
    ~about:"choose"
    ~desc:"when choose match auth, the user exists and password exists"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/auth/pierre/pierre-s-password1234"
        Services.error
        (R.make_ok ~env "root")
    in
    let expected = R.make_redirect ~env "https://private.com" in
    expected, computed)
;;

let test_choose_on_provided_page_when_user_is_not_connected =
  let env = [] in
  test_equality_lwt
    ~about:"choose"
    ~desc:"when choose match provided but the user is not connected"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/provided"
        Services.error
        (R.make_ok ~env "root")
    in
    let expected = R.make_error ~env "not connected" in
    expected, computed)
;;

let test_choose_on_provided_page_when_user_is_not_active =
  let env = [ "current_user", "not-active" ] in
  test_equality_lwt
    ~about:"choose"
    ~desc:"when choose match provided but the user is not active"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/provided"
        Services.error
        (R.make_ok ~env "root")
    in
    let expected = R.make_error ~env "not active" in
    expected, computed)
;;

let test_choose_on_provided_page_when_user_is_valid =
  let env = [ "current_user", "active" ] in
  test_equality_lwt
    ~about:"choose"
    ~desc:"when choose match provided and the user is active"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/provided"
        Services.error
        (R.make_ok ~env "root")
    in
    let expected = R.make_ok ~env "connected" in
    expected, computed)
;;

let test_choose_on_cheap_failable_auth_when_user_does_not_exists =
  let env =
    [ "dummy-variable", "1234"
    ; "allow-auth", "true"
    ; "pierre", "pierre-s-password1234"
    ]
  in
  test_equality_lwt
    ~about:"choose"
    ~desc:"when choose match auth, but the user does not exists"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/auth-failable/antoine/pierre-s-password1234"
        Services.error
        (R.make_ok ~env "root")
    in
    let expected = R.make_error ~env "unknown user" in
    expected, computed)
;;

let test_choose_on_cheap_failable_auth_when_password_not_match =
  let env =
    [ "dummy-variable", "1234"
    ; "allow-auth", "true"
    ; "pierre", "pierre-s-password1234"
    ]
  in
  test_equality_lwt
    ~about:"choose"
    ~desc:"when choose match auth, but the password does not match"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/auth-failable/pierre/pierre-s-password12345"
        Services.error
        (R.make_ok ~env "root")
    in
    let expected = R.make_error ~env "invalid password" in
    expected, computed)
;;

let test_choose_on_cheap_failable_auth_when_password_match =
  let env =
    [ "dummy-variable", "1234"
    ; "allow-auth", "true"
    ; "pierre", "pierre-s-password1234"
    ]
  in
  test_equality_lwt
    ~about:"choose"
    ~desc:"when choose match auth and the password match"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/auth-failable/pierre/pierre-s-password1234"
        Services.error
        (R.make_ok ~env "root")
    in
    let expected = R.make_ok ~env "Hello pierre" in
    expected, computed)
;;

let test_choose_on_binop_with_invalid_char =
  test_equality_lwt
    ~about:"choose"
    ~desc:"when choose match binop but the char is not an operator"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/binop/i/a/1/b/2"
        Services.error
        (R.make_ok "root")
    in
    let expected = R.make_error "unknown operator i" in
    expected, computed)
;;

let test_choose_on_binop_with_valid_char =
  test_equality_lwt
    ~about:"choose"
    ~desc:"when choose match binop and perform a computation"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/binop/*/a/2/b/9"
        Services.error
        (R.make_ok "root")
    in
    let expected = R.make_ok "18" in
    expected, computed)
;;

let test_choose_on_provided_auth_when_no_env =
  test_equality_lwt
    ~about:"choose"
    ~desc:
      "when choose match provided_auth but there is no current user connected"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/provided-auth"
        Services.error
        (R.make_ok "root")
    in
    let expected = R.make_error "not connected" in
    expected, computed)
;;

let test_choose_on_provided_auth_when_user_not_active =
  let env = [ "current_user", "inactive" ] in
  test_equality_lwt
    ~about:"choose"
    ~desc:"when choose match provided_auth but the current user is inactive"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/provided-auth"
        Services.error
        (R.make_ok ~env "root")
    in
    let expected = R.make_error ~env "not active" in
    expected, computed)
;;

let test_choose_on_provided_auth_when_user_is_active =
  let env = [ "current_user", "active" ] in
  test_equality_lwt
    ~about:"choose"
    ~desc:"when choose match provided_auth and the current user is active"
    R.testable
    (fun () ->
    let open Lwt.Syntax in
    let+ computed =
      Service.choose
        ~services
        ~given_method:`POST
        ~given_uri:"/provided-auth"
        Services.error
        (R.make_ok ~env "root")
    in
    let expected = R.make_ok ~env "welcome" in
    expected, computed)
;;

let cases =
  ( "Service"
  , [ test_choose_when_there_is_no_candidate_1
    ; test_choose_when_there_is_no_candidate_2
    ; test_choose_when_there_is_no_candidate_3
    ; test_choose_on_hello_world
    ; test_choose_on_sum
    ; test_choose_on_cheap_auth_when_auth_is_not_allowed
    ; test_choose_on_cheap_auth_when_user_does_not_exists
    ; test_choose_on_cheap_auth_when_password_does_not_match
    ; test_choose_on_cheap_auth_when_user_exists_and_password_match
    ; test_choose_on_provided_page_when_user_is_not_connected
    ; test_choose_on_provided_page_when_user_is_not_active
    ; test_choose_on_provided_page_when_user_is_valid
    ; test_choose_on_cheap_failable_auth_when_user_does_not_exists
    ; test_choose_on_cheap_failable_auth_when_password_not_match
    ; test_choose_on_cheap_failable_auth_when_password_match
    ; test_choose_on_binop_with_invalid_char
    ; test_choose_on_binop_with_valid_char
    ; test_choose_on_provided_auth_when_no_env
    ; test_choose_on_provided_auth_when_user_not_active
    ; test_choose_on_provided_auth_when_user_is_active
    ] )
;;
