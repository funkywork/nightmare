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

let method_testable =
  let open Nightmare_service in
  Alcotest.testable Method.pp Method.equal
;;

let test_to_string_from_string =
  test_equality
    ~about:"to_string & from_string"
    ~desc:
      "[to_string] should returns valid string and [from_string] should return \
       valid method wrapped in [Some]"
    Alcotest.(list @@ option method_testable)
    (fun () ->
      let open Nightmare_service.Method in
      let expected = List.map Option.some all
      and computed = List.map (fun meth -> from_string @@ to_string meth) all in
      expected, computed)
;;

let cases = "Method", [ test_to_string_from_string ]
