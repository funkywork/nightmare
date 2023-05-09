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

exception Not_supported

type ('key, 'value) change = ('key, 'value) Interfaces.storage_change_state =
  | Clear
  | Insert of
      { key : 'key
      ; value : 'value
      }
  | Remove of
      { key : 'key
      ; value : 'value
      }
  | Update of
      { key : 'key
      ; old_value : 'value
      ; new_value : 'value
      }

module type VALUE = Interfaces.STORAGE_SERIALIZABLE
module type REQUIREMENT = Interfaces.STORAGE_REQUIREMENT
module type S = Interfaces.STORAGE

module Make (Req : REQUIREMENT) = struct
  open Js_of_ocaml
  open Optional

  type key = string
  type value = string

  module Map = Map.Make (String)

  type slice = value Map.t

  let storage =
    Optional.Undefinable.fold
      (fun () -> raise Not_supported)
      (fun x -> x)
      Req.handler
  ;;

  let unwrap_string s =
    let open Option in
    Js.to_string <$> (s |> from_opt)
  ;;

  let length () = storage##.length
  let clear () = storage##clear
  let remove key = storage##removeItem (Js.string key)
  let get key = storage##getItem (Js.string key) |> unwrap_string
  let key i = storage##key i |> unwrap_string

  let set key value =
    let k = Js.string key
    and v = Js.string value in
    storage##setItem k v
  ;;

  let update f key =
    let previous_value = get key in
    let final_value = f previous_value in
    let () =
      match final_value with
      | None -> remove key
      | Some new_value -> set key new_value
    in
    final_value
  ;;

  let nth i =
    let open Option.Monad in
    let* k = key i in
    let+ v = get k in
    k, v
  ;;

  let fold f default =
    let len = length () in
    let rec aux acc i =
      if i < len
      then (
        match nth i with
        | None -> raise Not_found (* Should not happen. *)
        | Some (k, v) -> aux (f acc k v) (succ i))
      else acc
    in
    aux default 0
  ;;

  let filter predicate =
    fold
      (fun map key value ->
        if predicate key value then Map.add key value map else map)
      Map.empty
  ;;

  let to_map () = filter (fun _ _ -> true)
end

module Local = Make (struct
  let handler = Js_of_ocaml.Dom_html.window##.localStorage
end)

module Session = Make (struct
  let handler = Js_of_ocaml.Dom_html.window##.sessionStorage
end)
