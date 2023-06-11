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

type t = Bindings.form_data Js.t

let constr : (unit -> t) Js.constr = Js.Unsafe.global##._FormData

let append form_data ~key ~value =
  let key = Js.string key
  and value = Js.string value in
  let () = form_data##append key value in
  form_data
;;

let delete form_data ~key =
  let key = Js.string key in
  let () = form_data##delete key in
  form_data
;;

let get form_data ~key =
  let key = Js.string key in
  let open Nullable in
  Js.to_string <$> form_data##get key |> to_option
;;

let get_all form_data ~key =
  let key = Js.string key in
  form_data##getAll key |> Js.to_array |> Array.to_list |> List.map Js.to_string
;;

let has form_data ~key =
  let key = Js.string key in
  form_data##has key |> Js.to_bool
;;

let set form_data ~key ~value =
  let key = Js.string key
  and value = Js.string value in
  let () = form_data##set key value in
  form_data
;;

let make args =
  let form_data = new%js constr () in
  List.fold_left
    (fun form_data (key, value) -> append form_data ~key ~value)
    form_data
    args
;;
