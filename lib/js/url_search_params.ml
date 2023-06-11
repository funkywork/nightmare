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

type t = Bindings.url_search_params Js.t

let constr : (Js.js_string Js.t -> t) Js.constr =
  Js.Unsafe.global##._URLSearchParams
;;

let append url_search_params ~key ~value =
  let key = Js.string key
  and value = Js.string value in
  let () = url_search_params##append key value in
  url_search_params
;;

let delete url_search_params ~key =
  let key = Js.string key in
  let () = url_search_params##delete key in
  url_search_params
;;

let get url_search_params ~key =
  let key = Js.string key in
  let open Nullable in
  Js.to_string <$> url_search_params##get key |> to_option
;;

let get_all url_search_params ~key =
  let key = Js.string key in
  url_search_params##getAll key
  |> Js.to_array
  |> Array.to_list
  |> List.map Js.to_string
;;

let has url_search_params ~key =
  let key = Js.string key in
  url_search_params##has key |> Js.to_bool
;;

let set url_search_params ~key ~value =
  let key = Js.string key
  and value = Js.string value in
  let () = url_search_params##set key value in
  url_search_params
;;

let make query_string = new%js constr (Js.string query_string)

let sort url_search_params =
  let () = url_search_params##sort in
  url_search_params
;;

let to_string url_search_params = url_search_params##toString |> Js.to_string
