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

type 'a variable =
  | Record of
      { from_string : string -> 'a option
      ; to_string : 'a -> string
      ; name : string
      }
  | Module of (module Signatures.PATH_FRAGMENT with type t = 'a)

type (_, _) t =
  | Root : ('witness, 'witness) t
  | Const : ('continuation, 'witness) t * string -> ('continuation, 'witness) t
  | Var :
      ('continuation, 'new_variable -> 'witness) t * 'new_variable variable
      -> ('continuation, 'witness) t

type ('continuation, 'witness) wrapped = unit -> ('continuation, 'witness) t

let variable ~from_string ~to_string name =
  Record { from_string; to_string; name }
;;

let variable' (type a) (module PF : Signatures.PATH_FRAGMENT with type t = a) =
  Module (module PF)
;;

let variable_name : type a. a variable -> string = function
  | Record { name; _ } -> name
  | Module (module M) -> M.fragment_name
;;

let variable_to_string : type a. a variable -> a -> _ =
  fun fragment value ->
  match fragment with
  | Record { to_string; _ } -> to_string value
  | Module (module M) -> M.fragment_to_string value
;;

let variable_from_string : type a. a variable -> string -> a option =
  fun fragment value ->
  match fragment with
  | Record { from_string; _ } -> from_string value
  | Module (module M) -> M.fragment_from_string value
;;

module Preset = struct
  let string =
    variable ~from_string:Option.some ~to_string:(fun x -> x) "string"
  ;;

  let int =
    variable ~from_string:int_of_string_opt ~to_string:string_of_int "int"
  ;;

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
end

include Preset

let root = Root
let add_constant value base = Const (base, value)
let add_variable variable base = Var (base, variable)

module Infix = struct
  let ( ~/ ) value = add_constant value root
  let ( ~/: ) variable = add_variable variable root
  let ( / ) base value = add_constant value base
  let ( /: ) base variable = add_variable variable base
end

include Infix

let pp ppf path =
  let rec aux
    : type continuation witness.
      string list -> (continuation, witness) t -> string list
    =
    fun acc -> function
    | Root -> acc
    | Const (path_xs, x) -> aux (x :: acc) path_xs
    | Var (path_xs, fr) -> aux ((":" ^ variable_name fr) :: acc) path_xs
  in
  let str = aux [] path |> String.concat "/" in
  Format.fprintf ppf "/%s" str
;;

let sprintf_with path handler =
  let collapse_list x = handler ("/" ^ String.concat "/" @@ List.rev x) in
  let rec aux
    : type continuation witness.
      (string list -> witness) -> (continuation, witness) t -> continuation
    =
    fun continue -> function
    | Root -> continue []
    | Const (path_xs, x) -> aux (fun xs -> continue (x :: xs)) path_xs
    | Var (path_xs, fr) ->
      aux (fun xs w -> continue (variable_to_string fr w :: xs)) path_xs
  in
  aux collapse_list path
;;

let sprintf path = sprintf_with path (fun x -> x)

let sscanf path uri =
  let rec aux
    : type continuation witness normal_form.
      (witness -> normal_form)
      -> (continuation, witness) t
      -> string list
      -> continuation
      -> normal_form option
    =
    fun continue path fragments ->
    match path, fragments with
    | Root, [] -> fun x -> Some (continue x)
    | Const (path_xs, x), fragment :: uri_xs ->
      if String.equal x fragment
      then aux continue path_xs uri_xs
      else fun _ -> None
    | Var (path_xs, fr), fragment :: uri_xs ->
      Option.fold
        ~none:(fun _ -> None)
        ~some:(fun var -> aux (fun acc -> continue (acc var)) path_xs uri_xs)
      @@ variable_from_string fr fragment
    | _ -> fun _ -> None
  in
  let parsed = Parser.Href.from_string uri in
  let fragments = List.rev @@ Parser.Href.fragments parsed in
  aux (fun x -> x) path fragments
;;
