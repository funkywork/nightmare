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
open Optional

type t = Bindings.http_headers Js.t

let constr : (unit -> t) Js.constr = Js.Unsafe.global##._Headers

let append headers ~key ~value =
  let key = Js.string key
  and value = Js.string value in
  let () = headers##append key value in
  headers
;;

let delete headers ~key =
  let key = Js.string key in
  let () = headers##delete key in
  headers
;;

let get headers ~key =
  let key = Js.string key in
  let open Nullable in
  Js.to_string <$> headers##get key |> to_option
;;

let has headers ~key =
  let key = Js.string key in
  headers##has key |> Js.to_bool
;;

let set headers ~key ~value =
  let key = Js.string key
  and value = Js.string value in
  let () = headers##set key value in
  headers
;;

let make args =
  let headers = new%js constr () in
  List.fold_left
    (fun headers (key, value) -> append headers ~key ~value)
    headers
    args
;;
