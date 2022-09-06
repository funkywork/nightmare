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

open Nightmare_test

let href_testable =
  Alcotest.testable
    Nightmare_service.Parser.Href.pp
    Nightmare_service.Parser.Href.equal
;;

let test_href_empty_string =
  test_equality
    ~about:"Href.from_string"
    ~desc:"When the string is empty, it should produces an empty href"
    href_testable
    (fun () ->
    let open Nightmare_service.Parser.Href in
    let expected = make []
    and computed = from_string "" in
    expected, computed)
;;

let test_href_without_anchor_and_query_string =
  test_equality
    ~about:"Href.from_string"
    ~desc:
      "When the string has no anchor and query string, it should just parse \
       the fragments"
    href_testable
    (fun () ->
    let open Nightmare_service.Parser.Href in
    let expected = make [ "foo"; "bar"; "baz" ]
    and computed = from_string "foo/bar/baz" in
    expected, computed)
;;

let test_href_with_anchor_and_without_query_string =
  test_equality
    ~about:"Href.from_string"
    ~desc:
      "When the string has an anchor but no query string, it should just parse \
       the fragments and retreive the anchor"
    href_testable
    (fun () ->
    let open Nightmare_service.Parser.Href in
    let expected = make ~anchor:"foo-bar-baz" [ "foo"; "bar"; "baz" ]
    and computed = from_string "foo/bar/baz#foo-bar-baz" in
    expected, computed)
;;

let test_href_without_anchor_and_with_query_string =
  test_equality
    ~about:"Href.from_string"
    ~desc:
      "When the string has no anchor but a query string, it should just parse \
       the fragments and retreive the query string"
    href_testable
    (fun () ->
    let open Nightmare_service.Parser.Href in
    let expected = make ~query_string:"foo=bar&baz=foo" [ "foo"; "bar"; "baz" ]
    and computed = from_string "foo/bar/baz?foo=bar&baz=foo" in
    expected, computed)
;;

let test_href_with_anchor_and_with_query_string =
  test_equality
    ~about:"Href.from_string"
    ~desc:
      "When the string has an anchor but a query string, it should just parse \
       the fragments and retreive the query string and the anchor"
    href_testable
    (fun () ->
    let open Nightmare_service.Parser.Href in
    let expected =
      make
        ~query_string:"foo=bar&baz=foo"
        ~anchor:"foo-bar-baz"
        [ "foo"; "bar"; "baz" ]
    and computed = from_string "foo/bar/baz?foo=bar&baz=foo#foo-bar-baz" in
    expected, computed)
;;

let test_href_without_fragment_and_query_string_but_with_anchor =
  test_equality
    ~about:"Href.from_string"
    ~desc:"When the string has anchor and nothing else"
    href_testable
    (fun () ->
    let open Nightmare_service.Parser.Href in
    let expected = make ~anchor:"foo-bar-baz" []
    and computed = from_string "#foo-bar-baz" in
    expected, computed)
;;

let test_href_without_fragment_and_anchor_string_but_with_query_string =
  test_equality
    ~about:"Href.from_string"
    ~desc:"When the string has query string and nothing else"
    href_testable
    (fun () ->
    let open Nightmare_service.Parser.Href in
    let expected = make ~query_string:"foo=true&baz=bar" []
    and computed = from_string "?foo=true&baz=bar" in
    expected, computed)
;;

let test_href_without_fragment =
  test_equality
    ~about:"Href.from_string"
    ~desc:"When the string has query string and nothing else"
    href_testable
    (fun () ->
    let open Nightmare_service.Parser.Href in
    let expected =
      make ~query_string:"foo=true&baz=bar" ~anchor:"foo-bar-baz" []
    and computed = from_string "?foo=true&baz=bar#foo-bar-baz" in
    expected, computed)
;;

let cases =
  ( "Parser"
  , [ test_href_empty_string
    ; test_href_without_anchor_and_query_string
    ; test_href_with_anchor_and_without_query_string
    ; test_href_without_anchor_and_with_query_string
    ; test_href_with_anchor_and_with_query_string
    ; test_href_without_fragment_and_query_string_but_with_anchor
    ; test_href_without_fragment_and_anchor_string_but_with_query_string
    ; test_href_without_fragment
    ] )
;;
