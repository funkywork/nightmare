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

type 'a variable =
  { from_string : string -> 'a option
  ; to_string : 'a -> string
  ; name : string
  }

type (_, _) t =
  | Root : ('handler_return, 'handler_return) t
  | Const :
      ('handler_continuation, 'handler_return) t * string
      -> ('handler_continuation, 'handler_return) t
  | Var :
      ('handler_continuation, 'new_variable -> 'handler_return) t
      * 'new_variable variable
      -> ('handler_continuation, 'handler_return) t

let variable ~from_string ~to_string name = { from_string; to_string; name }
let string = variable ~from_string:Option.some ~to_string:(fun x -> x) "string"
let int = variable ~from_string:int_of_string_opt ~to_string:string_of_int "int"

let float =
  variable ~from_string:float_of_string_opt ~to_string:string_of_float "float"
;;

let bool =
  variable ~from_string:bool_of_string_opt ~to_string:string_of_bool "bool"
;;

let char =
  let is_char s = Int.equal 1 @@ String.length s in
  let from_string s = if is_char s then Some s.[0] else None in
  let to_string c = String.make 1 c in
  variable ~from_string ~to_string "char"
;;

let root = Root
let add_constant value base = Const (base, value)
let add_variable variable base = Var (base, variable)
let ( ~/ ) value = add_constant value root
let ( ~/: ) variable = add_variable variable root
let ( / ) base value = add_constant value base
let ( /: ) base variable = add_variable variable base

let pp ppf path =
  let rec aux
    : type handler_continuation handler_return.
      string list -> (handler_continuation, handler_return) t -> string list
    =
   fun acc -> function
    | Root -> acc
    | Const (path_xs, x) -> aux (x :: acc) path_xs
    | Var (path_xs, { name; _ }) -> aux ((":" ^ name) :: acc) path_xs
  in
  let str = aux [] path |> String.concat "/" in
  Format.fprintf ppf "/%s" str
;;

let sprintf_with path handler =
  let collapse_list x = handler ("/" ^ String.concat "/" @@ List.rev x) in
  let rec aux
    : type handler_continuation handler_return.
      (string list -> handler_return)
      -> (handler_continuation, handler_return) t
      -> handler_continuation
    =
   fun continue -> function
    | Root -> continue []
    | Const (path_xs, x) -> aux (fun xs -> continue (x :: xs)) path_xs
    | Var (path_xs, { to_string; _ }) ->
      aux (fun xs w -> continue (to_string w :: xs)) path_xs
  in
  aux collapse_list path
;;

let sprintf path = sprintf_with path (fun x -> x)

let sscanf_with path uri handler =
  let rec aux
    : type handler_continuation handler_return normal_form.
      (handler_return -> normal_form)
      -> (handler_continuation, handler_return) t
      -> string list
      -> handler_continuation
      -> normal_form option
    =
   fun continue path fragments ->
    match path, fragments with
    | Root, [] -> fun x -> Some (continue x)
    | Const (path_xs, x), fragment :: uri_xs ->
      if String.equal x fragment
      then aux continue path_xs uri_xs
      else fun _ -> None
    | Var (path_xs, { from_string; _ }), fragment :: uri_xs ->
      Option.fold
        ~none:(fun _ -> None)
        ~some:(fun var -> aux (fun acc -> continue (acc var)) path_xs uri_xs)
      @@ from_string fragment
    | _ -> fun _ -> None
  in
  let parsed = Parser.Href.from_string uri in
  let fragments = List.rev @@ Parser.Href.fragments parsed in
  aux handler path fragments
;;

let sscanf path uri = sscanf_with path uri (fun x -> x)
