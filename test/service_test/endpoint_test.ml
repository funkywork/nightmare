(*  MIT License

    Copyright (c) 2022 funkywork

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

module Md5 : sig
  type t

  val hash : string -> t
  val variable : t Nightmare_service.Path.variable
end = struct
  type t = Digest.t

  let hash x =
    let s = String.(trim @@ lowercase_ascii x) in
    Digest.(to_hex @@ string s)
  ;;

  let to_string x = x
  let from_string x = Some x
  let variable = Nightmare_service.Path.variable ~from_string ~to_string "md5"
end

module Sample = struct
  open Nightmare_service
  open Path
  open Endpoint

  let i1 () = get root
  let i2 () = get (~/"foo" / "bar" / "baz")
  let i3 () = get (~/"user" /: string /: int)
  let i4 () = post (~/"new" / "message" /: string)
  let i5 () = post (~/"name" /: string / "age" /: int / "active" /: bool)
  let github () = outer get "https://github.com" ~/:string

  let gravatar () =
    outer get "https://www.gravatar.com" (~/"avatar" /: Md5.variable)
  ;;
end

open Nightmare_test

let test_href_over_inner_links =
  test_equality
    ~about:"href"
    ~desc:"generate a bunch of inner links"
    Alcotest.(list string)
    (fun () ->
      let open Nightmare_service.Endpoint in
      let expected =
        [ "/"
        ; "/#foo"
        ; "/?foo=bar&bar=baz"
        ; "/?bar=foo#fw"
        ; "/foo/bar/baz"
        ; "/foo/bar/baz#foo"
        ; "/foo/bar/baz?foo=bar&bar=baz"
        ; "/foo/bar/baz?bar=foo#fw"
        ; "/user/gr-im/25"
        ; "/user/xvw/32#foo"
        ; "/user/xhtmlboi/999?foo=bar&bar=baz"
        ; "/user/msp/26?bar=foo#fw"
        ]
      and computed =
        [ href ~:Sample.i1
        ; href ~anchor:"foo" ~:Sample.i1
        ; href ~parameters:[ "foo", "bar"; "bar", "baz" ] ~:Sample.i1
        ; href ~parameters:[ "bar", "foo" ] ~anchor:"fw" ~:Sample.i1
        ; href ~:Sample.i2
        ; href ~anchor:"foo" ~:Sample.i2
        ; href ~parameters:[ "foo", "bar"; "bar", "baz" ] ~:Sample.i2
        ; href ~parameters:[ "bar", "foo" ] ~anchor:"fw" ~:Sample.i2
        ; href ~:Sample.i3 "gr-im" 25
        ; href ~anchor:"foo" ~:Sample.i3 "xvw" 32
        ; href
            ~parameters:[ "foo", "bar"; "bar", "baz" ]
            ~:Sample.i3
            "xhtmlboi"
            999
        ; href ~parameters:[ "bar", "foo" ] ~anchor:"fw" ~:Sample.i3 "msp" 26
        ]
      in
      expected, computed)
;;

let test_href_over_github =
  test_equality
    ~about:"href"
    ~desc:"generate some bunch of links for github"
    Alcotest.(list string)
    (fun () ->
      let open Nightmare_service.Endpoint in
      let expected =
        [ "https://github.com/gr-im"
        ; "https://github.com/funkywork#hello"
        ; "https://github.com/xvw?tab=repositories"
        ; "https://github.com/xhtmlboi?tab=repositories#bottom"
        ]
      and computed =
        [ href ~:Sample.github "gr-im"
        ; href ~anchor:"hello" ~:Sample.github "funkywork"
        ; href ~parameters:[ "tab", "repositories" ] ~:Sample.github "xvw"
        ; href
            ~parameters:[ "tab", "repositories" ]
            ~anchor:"bottom"
            ~:Sample.github
            "xhtmlboi"
        ]
      in
      expected, computed)
;;

let test_href_over_gravatar =
  test_equality
    ~about:"href"
    ~desc:"generate some bunch of links for gravatar"
    Alcotest.(list string)
    (fun () ->
      let open Nightmare_service.Endpoint in
      let xhtmlboi_hash = Md5.hash "xhtmlboi@gmail.com"
      and xvw_hash = Md5.hash "xaviervdw@gmail.com" in
      let expected =
        [ "https://www.gravatar.com/avatar/cd3df8ee791afc59b05feddfc4783cf2"
        ; "https://www.gravatar.com/avatar/77147495ce1de81bd3b4d4044b8367fd"
        ]
      and computed =
        [ href ~:Sample.gravatar xhtmlboi_hash
        ; href ~:Sample.gravatar xvw_hash
        ]
      in
      expected, computed)
;;

let test_form_method_for_links =
  test_equality
    ~about:"form_method"
    ~desc:"retreive a bunch of form method for endpoints"
    Alcotest.(
      list
      @@ testable Nightmare_service.Method.pp Nightmare_service.Method.equal)
    (fun () ->
      let open Nightmare_service.Endpoint in
      let expected = [ `GET; `GET; `GET; `POST; `POST; `GET; `GET ]
      and computed =
        [ form_method ~:Sample.i1
        ; form_method ~:Sample.i2
        ; form_method ~:Sample.i3
        ; form_method ~:Sample.i4
        ; form_method ~:Sample.i5
        ; form_method ~:Sample.github
        ; form_method ~:Sample.gravatar
        ]
      in
      expected, computed)
;;

let test_form_action_for_links =
  test_equality
    ~about:"form_action"
    ~desc:"retreive a bunch of form action for endpoints"
    Alcotest.(list string)
    (fun () ->
      let open Nightmare_service.Endpoint in
      let expected =
        [ "/"
        ; "/foo/bar/baz"
        ; "/user/gr-im/25#bottom"
        ; "/new/message/im-a-message"
        ; "/name/Pierre/age/25/active/true"
        ; "https://github.com/funkywork?foo=bar&hello=true"
        ; "https://www.gravatar.com/avatar/5eb63bbbe01eeed093cb22bb8f5acdc3"
        ]
      and computed =
        [ form_action ~:Sample.i1
        ; form_action ~:Sample.i2
        ; form_action ~:Sample.i3 ~anchor:"bottom" "gr-im" 25
        ; form_action ~:Sample.i4 "im-a-message"
        ; form_action ~:Sample.i5 "Pierre" 25 true
        ; form_action
            ~:Sample.github
            ~parameters:[ "foo", "bar"; "hello", "true" ]
            "funkywork"
        ; form_action ~:Sample.gravatar (Md5.hash "hello world")
        ]
      in
      expected, computed)
;;

let test_sscanf_for_links =
  test_equality
    ~about:"sscanf"
    ~desc:"handle some valid links and invalid links"
    Alcotest.(list @@ option string)
    (fun () ->
      let open Nightmare_service.Endpoint in
      let expected =
        [ Some "on root"
        ; None
        ; Some "/foo/bar/baz"
        ; None
        ; Some "Pierre/25"
        ; None
        ; None
        ]
      and computed =
        [ sscanf ~:Sample.i1 `GET (href ~anchor:"f" ~:Sample.i1) "on root"
        ; sscanf ~:Sample.i1 `GET "/foo" "on root"
        ; sscanf ~:Sample.i2 `GET (href ~:Sample.i2) "/foo/bar/baz"
        ; sscanf ~:Sample.i2 `GET "/foo/baz/bar" "on /foo/bar/baz"
        ; sscanf
            ~:Sample.i3
            `GET
            (href ~:Sample.i3 "Pierre" 25)
            (Format.asprintf "%s/%d")
        ; sscanf ~:Sample.i3 `GET "/foo/baz/bar" (Format.asprintf "%s/%d")
        ; sscanf
            ~:Sample.i3
            `CONNECT
            (href ~:Sample.i3 "Pierre" 25)
            (Format.asprintf "%s/%d")
        ]
      in
      expected, computed)
;;

let cases =
  ( "Endpoint"
  , [ test_href_over_github
    ; test_href_over_gravatar
    ; test_href_over_inner_links
    ; test_form_method_for_links
    ; test_form_action_for_links
    ; test_sscanf_for_links
    ] )
;;
