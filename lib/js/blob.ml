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

open Js_of_ocaml

type t = Bindings.blob Js.t

let size b = b##.size
let content_type b = b##._type |> Js.to_string
let array_buffer b = b##arrayBuffer |> Promise.as_lwt

let slice ?content_type ~start ~stop b =
  let open Optional.Option in
  let content_type = Js.string <$> content_type |> to_optdef in
  b##slice start stop content_type
;;

let stream b = b##stream

let text b =
  let open Lwt.Syntax in
  let+ tarr = b##text |> Promise.as_lwt in
  Js.to_string tarr
;;

let constr = Js.Unsafe.global##._Blob

let make ?content_type values =
  let open Optional.Option in
  let content_type =
    (fun ct ->
      object%js
        val _type = Js.string ct
      end)
    <$> content_type
    |> to_optdef
  in
  let values = Util.from_list_to_js_array Js.string values in
  new%js constr values content_type
;;
