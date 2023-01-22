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

let html_testable =
  Alcotest.testable (Tyxml.Html.pp_elt ~indent:true ()) (fun a b ->
    let a = Format.asprintf "%a" (Tyxml.Html.pp_elt ()) a
    and b = Format.asprintf "%a" (Tyxml.Html.pp_elt ()) b in
    String.equal a b)
;;

module E = struct
  open Nightmare_service.Endpoint

  let home () = get ~/"home"
  let user () = get (~/"user" / "name" /: string)
  let repo () = outer get "https://github.com" (~/:string /: string)
  let base () = outer get "https://funkywork.io" ~/:string
  let media () = get (~/"files" /: string /: string)
  let pub () = post ~/"pub"
end

let test_a_of =
  test_equality
    ~about:"a_of"
    ~desc:"check that generated HTML has the right form"
    html_testable
    (fun () ->
    let open Tyxml.Html in
    let open Nightmare_tyxml in
    let expected =
      footer
        ~a:[ a_class [ "footer" ] ]
        [ p [ txt "Here are some links:" ]
        ; ul
            [ li
                [ a ~a:[ a_href "/home#content" ] [ txt "Go to the homepage" ] ]
            ; li
                [ a ~a:[ a_href "/user/name/grm" ] [ txt "Visit GRM profile" ] ]
            ; li
                [ a ~a:[ a_href "/user/name/xvw" ] [ txt "Visit XVW profile" ] ]
            ; li
                [ a
                    ~a:[ a_href "/user/name/xml?foo=bar" ]
                    [ txt "Visit XHTMLBoy profile" ]
                ]
            ; li
                [ a
                    ~a:
                      [ a_href "https://github.com/funkywork/nightmare"
                      ; a_target "_blank"
                      ]
                    [ txt "Visit Nightmare repository" ]
                ]
            ]
        ]
    and computed =
      footer
        ~a:[ a_class [ "footer" ] ]
        [ p [ txt "Here are some links:" ]
        ; ul
            [ li [ a_of E.home ~anchor:"content" [ txt "Go to the homepage" ] ]
            ; li [ a_of E.user "grm" [ txt "Visit GRM profile" ] ]
            ; li [ a_of E.user "xvw" [ txt "Visit XVW profile" ] ]
            ; li
                [ a_of
                    ~parameters:[ "foo", "bar" ]
                    E.user
                    "xml"
                    [ txt "Visit XHTMLBoy profile" ]
                ]
            ; li
                [ a_of
                    ~a:[ a_target "_blank" ]
                    E.repo
                    "funkywork"
                    "nightmare"
                    [ txt "Visit Nightmare repository" ]
                ]
            ]
        ]
    in
    expected, computed)
;;

let test_base_of =
  test_equality
    ~about:"base_of"
    ~desc:"check that generated HTML has the right form"
    html_testable
    (fun () ->
    let open Tyxml.Html in
    let open Nightmare_tyxml in
    let expected =
      base ~a:[ a_href "https://funkywork.io/base"; a_id "base-elt" ] ()
    and computed = base_of ~a:[ a_id "base-elt" ] E.base "base" in
    expected, computed)
;;

let test_embed_of =
  test_equality
    ~about:"embed_of"
    ~desc:"check that generated HTML has the right form"
    html_testable
    (fun () ->
    let open Tyxml.Html in
    let open Nightmare_tyxml in
    let expected =
      embed
        ~a:
          [ a_src "/files/movies/clip.mp4?autoplay=true"
          ; a_width 250
          ; a_height 456
          ]
        ()
    and computed =
      embed_of
        ~parameters:[ "autoplay", "true" ]
        ~a:[ a_width 250; a_height 456 ]
        E.media
        "movies"
        "clip.mp4"
    in
    expected, computed)
;;

let test_form_of =
  test_equality
    ~about:"form_of"
    ~desc:"check that generated HTML has the right form"
    html_testable
    (fun () ->
    let open Tyxml.Html in
    let open Nightmare_tyxml in
    let expected =
      form
        ~a:[ a_action "/pub"; a_method `Post ]
        [ input ~a:[ a_name "foo"; a_input_type `Text ] ()
        ; input ~a:[ a_name "bar"; a_input_type `Text ] ()
        ; input ~a:[ a_name "submit"; a_input_type `Submit ] ()
        ]
    and computed =
      form_of
        E.pub
        [ input ~a:[ a_name "foo"; a_input_type `Text ] ()
        ; input ~a:[ a_name "bar"; a_input_type `Text ] ()
        ; input ~a:[ a_name "submit"; a_input_type `Submit ] ()
        ]
    in
    expected, computed)
;;

let test_form_with_csrf_of =
  test_equality
    ~about:"form_of"
    ~desc:"check that generated HTML has the right form (and include CSRF)"
    html_testable
    (fun () ->
    let open Tyxml.Html in
    let open Nightmare_tyxml in
    let expected =
      form
        ~a:[ a_action "/user/name/grm?bar=foo&lang=ocaml"; a_method `Get ]
        [ input
            ~a:
              [ a_input_type `Hidden
              ; a_name "dream.csrf"
              ; a_value "!@#$%YHJKL"
              ]
            ()
        ; input ~a:[ a_name "foo"; a_input_type `Text ] ()
        ; input ~a:[ a_name "bar"; a_input_type `Text ] ()
        ; input ~a:[ a_name "submit"; a_input_type `Submit ] ()
        ]
    and computed =
      form_of
        ~csrf_token:("dream.csrf", "!@#$%YHJKL")
        ~parameters:[ "bar", "foo"; "lang", "ocaml" ]
        E.user
        "grm"
        [ input ~a:[ a_name "foo"; a_input_type `Text ] ()
        ; input ~a:[ a_name "bar"; a_input_type `Text ] ()
        ; input ~a:[ a_name "submit"; a_input_type `Submit ] ()
        ]
    in
    expected, computed)
;;

let test_iframe_of =
  test_equality
    ~about:"iframe_of"
    ~desc:"check that generated HTML has the right form"
    html_testable
    (fun () ->
    let open Tyxml.Html in
    let open Nightmare_tyxml in
    let expected =
      iframe
        ~a:[ a_src "https://github.com/xvw/preface"; a_name "frame-2" ]
        [ txt "test" ]
    and computed =
      iframe_of ~a:[ a_name "frame-2" ] E.repo "xvw" "preface" [ txt "test" ]
    in
    expected, computed)
;;

let test_img_of =
  test_equality
    ~about:"img_of"
    ~desc:"check that generated HTML has the right form"
    html_testable
    (fun () ->
    let open Tyxml.Html in
    let open Nightmare_tyxml in
    let expected = img ~alt:"a kip" ~src:"/files/media/kip.jpg" ()
    and computed = img_of E.media "media" "kip.jpg" ~alt:"a kip" in
    expected, computed)
;;

let test_link_of =
  test_equality
    ~about:"link_of"
    ~desc:"check that generated HTML has the right form"
    html_testable
    (fun () ->
    let open Tyxml.Html in
    let open Nightmare_tyxml in
    let expected = link ~rel:[ `Stylesheet ] ~href:"/files/css/default.css" ()
    and computed = link_of ~rel:[ `Stylesheet ] E.media "css" "default.css" in
    expected, computed)
;;

let test_object_of =
  test_equality
    ~about:"object_of"
    ~desc:"check that generated HTML has the right form"
    html_testable
    (fun () ->
    let open Tyxml.Html in
    let open Nightmare_tyxml in
    let expected =
      object_
        ~a:
          [ a_data "/files/media/clip.mp4"
          ; a_width 200
          ; a_height 300
          ; a_mime_type "video/mp4"
          ]
        [ txt "foo" ]
    and computed =
      object_of
        ~a:[ a_width 200; a_height 300; a_mime_type "video/mp4" ]
        E.media
        "media"
        "clip.mp4"
        [ txt "foo" ]
    in
    expected, computed)
;;

let test_script_of =
  test_equality
    ~about:"script_of"
    ~desc:"check that generated HTML has the right form"
    html_testable
    (fun () ->
    let open Tyxml.Html in
    let open Nightmare_tyxml in
    let expected =
      script
        ~a:[ a_src "/files/js/front.js"; a_mime_type "application/javascript" ]
        (txt "hello")
    and computed =
      script_of
        ~a:[ a_mime_type "application/javascript" ]
        E.media
        "js"
        "front.js"
        (txt "hello")
    in
    expected, computed)
;;

let test_source_of =
  test_equality
    ~about:"source_of"
    ~desc:"check that generated HTML has the right form"
    html_testable
    (fun () ->
    let open Tyxml.Html in
    let open Nightmare_tyxml in
    let expected =
      source ~a:[ a_src "/files/video/movie.mp4"; a_mime_type "video/mp4" ] ()
    and computed =
      source_of ~a:[ a_mime_type "video/mp4" ] E.media "video" "movie.mp4"
    in
    expected, computed)
;;

let cases =
  ( "Element"
  , [ test_a_of
    ; test_base_of
    ; test_embed_of
    ; test_form_of
    ; test_form_with_csrf_of
    ; test_iframe_of
    ; test_img_of
    ; test_link_of
    ; test_object_of
    ; test_script_of
    ; test_source_of
    ] )
;;
