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

let test_sprintf_on_root =
  test_equality
    ~about:"sprintf"
    ~desc:"[sprintf] on root should produce `/`"
    Alcotest.string
    (fun () ->
       let open Nightmare_service.Path in
       let expected = "/"
       and computed = sprintf root in
       expected, computed)
;;

let test_sprintf_on_path_without_variables =
  test_equality
    ~about:"sprintf"
    ~desc:
      "[sprintf] on a path without variable should produce a link without \
       continuation"
    Alcotest.string
    (fun () ->
       let open Nightmare_service.Path in
       let expected = "/foo/bar/baz"
       and computed = sprintf (~/"foo" / "bar" / "baz") in
       expected, computed)
;;

let test_sprintf_on_path_with_variables =
  test_equality
    ~about:"sprintf"
    ~desc:
      "[sprintf] on a path with variables should produce a link with \
       continuation"
    Alcotest.string
    (fun () ->
       let open Nightmare_service.Path in
       let expected = "/get_message/42/by_user/grm/in_category/global"
       and computed =
         sprintf
           (~/"get_message"
            /: int
            / "by_user"
            /: string
            / "in_category"
            /: string)
           42
           "grm"
           "global"
       in
       expected, computed)
;;

let test_sscanf_on_root_with_valid_uri =
  test_equality
    ~about:"sscanf"
    ~desc:
      "[sscanf] on the root with a valid uri should handle the given callback"
    Alcotest.(option bool)
    (fun () ->
      let open Nightmare_service.Path in
      let expected = Some true
      and computed = sscanf root "/" true in
      expected, computed)
;;

let test_sscanf_on_root_with_invalid_uri =
  test_equality
    ~about:"sscanf"
    ~desc:
      "[sscanf] on the root with an invalid uri should not handle the given \
       callback"
    Alcotest.(option bool)
    (fun () ->
      let open Nightmare_service.Path in
      let expected = None
      and computed = sscanf root "/foo/bar" true in
      expected, computed)
;;

let test_sscanf_on_path_without_variables_and_with_valid_uri =
  test_equality
    ~about:"sscanf"
    ~desc:
      "[sscanf] on a path without variables and  with a valid uri should \
       handle the given callback"
    Alcotest.(option bool)
    (fun () ->
      let open Nightmare_service.Path in
      let path = ~/"foo" / "bar" / "baz" in
      let expected = Some true
      and computed = sscanf path "/foo/bar/baz?foo=true#to-be-erased" true in
      expected, computed)
;;

let test_sscanf_on_path_without_variables_and_with_invalid_uri =
  test_equality
    ~about:"sscanf"
    ~desc:
      "[sscanf] on a path without variables and  with an invalid uri should \
       not handle the given callback"
    Alcotest.(option bool)
    (fun () ->
      let open Nightmare_service.Path in
      let path = ~/"foo" / "bar" / "baz" in
      let expected = None
      and computed = sscanf path "/foo/bra/baz#to-be-erased" true in
      expected, computed)
;;

let test_sscanf_on_path_with_variables_and_with_valid_uri =
  test_equality
    ~about:"sscanf"
    ~desc:
      "[sscanf] on a path with variables and with valid uri should handle the \
       given callback"
    Alcotest.(option @@ triple int string string)
    (fun () ->
      let open Nightmare_service.Path in
      let path =
        ~/"get_message" /: int / "by_user" /: string / "in_category" /: string
      in
      let expected = Some (42, "grm", "foo")
      and computed =
        sscanf path "/get_message/42/by_user/grm/in_category/foo" (fun n u c ->
          n, u, c)
      in
      expected, computed)
;;

let test_sscanf_on_path_with_variables_and_with_invalid_uri =
  test_equality
    ~about:"sscanf"
    ~desc:
      "[sscanf] on a path with variables and with an invalid uri should not \
       handle the given callback"
    Alcotest.(option @@ triple int string string)
    (fun () ->
      let open Nightmare_service.Path in
      let path =
        ~/"get_message" /: int / "by_user" /: string / "in_category" /: string
      in
      let expected = None
      and computed =
        sscanf path "/get_message/42/by_urse/grm/in_category/foo" (fun n u c ->
          n, u, c)
      in
      expected, computed)
;;

let test_sscanf_on_path_with_variables_and_with_invalid_type =
  test_equality
    ~about:"sscanf"
    ~desc:
      "[sscanf] on a path with variables and with an invalid type repr should \
       not handle the given callback"
    Alcotest.(option @@ triple int string string)
    (fun () ->
      let open Nightmare_service.Path in
      let path =
        ~/"get_message" /: int / "by_user" /: string / "in_category" /: string
      in
      let expected = None
      and computed =
        sscanf path "/get_message/NaN/by_urse/grm/in_category/foo" (fun n u c ->
          n, u, c)
      in
      expected, computed)
;;

let test_pp_1 =
  test_equality
    ~about:"pp"
    ~desc:"using [pp] - test 1"
    Alcotest.string
    (fun () ->
       let open Nightmare_service.Path in
       let expected = "/"
       and computed = Format.asprintf "%a" pp root in
       expected, computed)
;;

let test_pp_2 =
  test_equality
    ~about:"pp"
    ~desc:"using [pp] - test 2"
    Alcotest.string
    (fun () ->
       let open Nightmare_service.Path in
       let expected = "/foo/bar/baz"
       and computed = Format.asprintf "%a" pp (~/"foo" / "bar" / "baz") in
       expected, computed)
;;

let test_pp_3 =
  test_equality
    ~about:"pp"
    ~desc:"using [pp] - test 3"
    Alcotest.string
    (fun () ->
       let open Nightmare_service.Path in
       let expected = "/foo/:int/baz/:string/:float"
       and computed =
         Format.asprintf "%a" pp (~/"foo" /: int / "baz" /: string /: float)
       in
       expected, computed)
;;

let cases =
  ( "Path"
  , [ test_sprintf_on_root
    ; test_sprintf_on_path_without_variables
    ; test_sprintf_on_path_with_variables
    ; test_sscanf_on_root_with_valid_uri
    ; test_sscanf_on_root_with_invalid_uri
    ; test_sscanf_on_path_without_variables_and_with_valid_uri
    ; test_sscanf_on_path_without_variables_and_with_invalid_uri
    ; test_sscanf_on_path_with_variables_and_with_valid_uri
    ; test_sscanf_on_path_with_variables_and_with_invalid_uri
    ; test_sscanf_on_path_with_variables_and_with_invalid_type
    ; test_pp_1
    ; test_pp_2
    ; test_pp_3
    ] )
;;
