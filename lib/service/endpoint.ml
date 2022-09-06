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

(* here, ['k] means ['handler_continuation] and ['r] means ['handler_return]. *)

type (_, _, _) path =
  | GET : ('k, 'r) Path.t -> ([> `GET ], 'k, 'r) path
  | POST : ('k, 'r) Path.t -> ([> `POST ], 'k, 'r) path
  | PUT : ('k, 'r) Path.t -> ([> `PUT ], 'k, 'r) path
  | DELETE : ('k, 'r) Path.t -> ([> `DELETE ], 'k, 'r) path
  | HEAD : ('k, 'r) Path.t -> ([> `HEAD ], 'k, 'r) path
  | CONNECT : ('k, 'r) Path.t -> ([> `CONNECT ], 'k, 'r) path
  | OPTIONS : ('k, 'r) Path.t -> ([> `OPTIONS ], 'k, 'r) path
  | TRACE : ('k, 'r) Path.t -> ([> `TRACE ], 'k, 'r) path
  | PATCH : ('k, 'r) Path.t -> ([> `PATCH ], 'k, 'r) path

type (_, _, _, _) t =
  | Inner : ('m, 'k, 'r) path -> ([> `Inner ], 'm, 'k, 'r) t
  | Outer : string * ('m, 'k, 'r) path -> ([> `Outer ], 'm, 'k, 'r) t

let inner x = Inner x
let get x = inner @@ GET x
let post x = inner @@ POST x
let put x = inner @@ PUT x
let delete x = inner @@ DELETE x
let head x = inner @@ HEAD x
let connect x = inner @@ CONNECT x
let options x = inner @@ OPTIONS x
let trace x = inner @@ TRACE x
let patch x = inner @@ PATCH x

let outer
  :  (('handler_continuation, 'handler_return) Path.t
      -> ([ `Inner ], 'method_, 'handler_continuation, 'handler_return) t)
  -> string -> ('handler_continuation, 'handler_return) Path.t
  -> ([> `Outer ], 'method_, 'handler_continuation, 'handler_return) t
  =
 fun f prefix path ->
  match f path with
  | Inner p -> Outer (prefix, p)
;;

let get_path
  : type method_ handler_continuation handler_return.
    (method_, handler_continuation, handler_return) path
    -> (handler_continuation, handler_return) Path.t
  = function
  | GET p
  | POST p
  | PUT p
  | DELETE p
  | HEAD p
  | CONNECT p
  | OPTIONS p
  | TRACE p
  | PATCH p -> p
;;

let handle_path_with
  : type scope method_ handler_continuation handler_return.
    (scope, method_, handler_continuation, handler_return) t
    -> (string -> handler_return)
    -> handler_continuation
  =
 fun endpoint handler ->
  match endpoint with
  | Inner p ->
    let path = get_path p in
    Path.sprintf_with path handler
  | Outer (suffix, p) ->
    let path = get_path p in
    Path.sprintf_with path (fun str -> handler @@ suffix ^ str)
;;

let render_anchor = function
  | None -> ""
  | Some x -> if String.(equal x empty) then "" else "#" ^ x
;;

let render_key_value key value = key ^ "=" ^ value

let render_parameters = function
  | None | Some [] -> ""
  | Some params ->
    let query_string =
      List.fold_left
        (fun acc (key, value) ->
          let key_value = render_key_value key value in
          match acc with
          | None -> Some key_value
          | Some x -> Some (x ^ "&" ^ key_value))
        None
        params
    in
    Option.fold ~none:"" ~some:(fun qs -> "?" ^ qs) query_string
;;

let href_with ?anchor ?parameters endpoint handler =
  let anchor = render_anchor anchor
  and query_string = render_parameters parameters in
  handle_path_with endpoint (fun link ->
    handler @@ link ^ query_string ^ anchor)
;;

let href ?anchor ?parameters endpoint =
  href_with ?anchor ?parameters endpoint (fun x -> x)
;;

let form_action_with = href_with
let form_action = href

let form_method
  : (_, Method.for_form_action, _, _) t -> [> Method.for_form_action ]
  = function
  | Inner (GET _) | Outer (_, GET _) -> `GET
  | Inner (POST _) | Outer (_, POST _) -> `POST
;;

let sscanf endpoint given_method given_uri =
  let aux : ([ `Inner ], Method.t, _, _) t -> _ =
   fun (Inner p) ->
    match p, (given_method :> Method.t) with
    | GET path, `GET
    | POST path, `POST
    | PUT path, `PUT
    | DELETE path, `DELETE
    | HEAD path, `HEAD
    | CONNECT path, `CONNECT
    | OPTIONS path, `OPTIONS
    | TRACE path, `TRACE
    | PATCH path, `PATCH -> Path.sscanf path given_uri
    | _ -> fun _ -> None
  in
  aux endpoint
;;
