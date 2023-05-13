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
      ; old_value : 'value
      }
  | Update of
      { key : 'key
      ; old_value : 'value
      ; new_value : 'value
      }

module type VALUE = Interfaces.STORAGE_SERIALIZABLE
module type KEY = Interfaces.PREFIXED_KEY
module type REQUIREMENT = Interfaces.STORAGE_REQUIREMENT
module type S = Interfaces.STORAGE

type event = Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t

let event = Js_of_ocaml.Dom.Event.make "storage"

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

  let make_change_state (event : Dom_html.storageEvent Js.t) k =
    let key = Js.to_string k in
    let old_value = unwrap_string event##.oldValue in
    let new_value = unwrap_string event##.newValue in
    match old_value, new_value with
    | None, Some value -> Insert { key; value }
    | Some old_value, None -> Remove { key; old_value }
    | Some old_value, Some new_value -> Update { key; old_value; new_value }
    | None, None -> Clear
  ;;

  let pertinent_storage ev =
    let open Nullable in
    (let* area = ev##.storageArea in
     let+ curr = from_optdef Req.handler in
     area = curr)
    |> value ~default:false
  ;;

  let has_prefix ~prefix str =
    let prefix = Js.string prefix in
    let index = str##lastIndexOf_from prefix 0 in
    Int.equal index 0
  ;;

  let on ?capture ?once ?passive ?(prefix = "") f =
    let capture = Option.(Js.bool <$> capture) in
    let once = Option.(Js.bool <$> once) in
    let passive = Option.(Js.bool <$> passive) in
    let callback event =
      if pertinent_storage event
      then (
        let () =
          match Nullable.to_option event##.key with
          | None -> f Clear event
          | Some k ->
            if has_prefix ~prefix k then f (make_change_state event k) event
        in
        Js._true)
      else Js._true
    in
    Dom.addEventListenerWithOptions
      Dom_html.window
      event
      ?capture
      ?once
      ?passive
      (Dom.handler callback)
  ;;

  let on_clear ?capture ?once ?passive f =
    on ?capture ?once ?passive (fun state ev ->
      match state with
      | Clear -> f ev
      | _ -> ())
  ;;

  let on_insert ?capture ?once ?passive ?prefix f =
    on ?capture ?once ?passive ?prefix (fun state ev ->
      match state with
      | Insert { key; value } -> f ~key ~value ev
      | _ -> ())
  ;;

  let on_remove ?capture ?once ?passive ?prefix f =
    on ?capture ?once ?passive ?prefix (fun state ev ->
      match state with
      | Remove { key; old_value } -> f ~key ~old_value ev
      | _ -> ())
  ;;

  let on_update ?capture ?once ?passive ?prefix f =
    on ?capture ?once ?passive ?prefix (fun state ev ->
      match state with
      | Update { key; old_value; new_value } -> f ~key ~old_value ~new_value ev
      | _ -> ())
  ;;
end

module Local = Make (struct
  let handler = Js_of_ocaml.Dom_html.window##.localStorage
end)

module Session = Make (struct
  let handler = Js_of_ocaml.Dom_html.window##.sessionStorage
end)

let separator = "\x01"
let terminator = "\x00"

module Ref
  (Backend : S with type key = string and type value = string)
  (Key : KEY)
  (Value : VALUE) =
struct
  type t = Ref of string

  let complete_prefix =
    "nightmare" ^ separator ^ "ref" ^ separator ^ Key.prefix ^ separator
  ;;

  let make_prefixed_key value = complete_prefix ^ value ^ terminator
  let make key = Ref (make_prefixed_key key)

  let has_terminator prefix s =
    if String.ends_with ~suffix:prefix s then Some s else None
  ;;

  let set (Ref k) v =
    let value = Value.write v in
    Backend.set k value
  ;;

  let make_with k v =
    let reference = make k in
    let () = set reference v in
    reference
  ;;

  let get (Ref k) =
    let open Optional.Option in
    Backend.get k >>= Value.read
  ;;

  let make_if_not_exists k v =
    let reference = make k in
    let () =
      match get reference with
      | None -> set reference v
      | Some _ -> ()
    in
    reference
  ;;

  let on ?capture ?once ?passive ~key f =
    let prefix = make_prefixed_key key in
    let callback change event =
      let new_state =
        let open Optional.Option in
        match change with
        | Clear -> Some Clear
        | Insert { key; value } ->
          let* key = has_terminator prefix key >|= make in
          let+ value = Value.read value in
          Insert { key; value }
        | Remove { key; old_value } ->
          let* key = has_terminator prefix key >|= make in
          let+ old_value = Value.read old_value in
          Remove { key; old_value }
        | Update { key; old_value; new_value } ->
          let* key = has_terminator prefix key >|= make in
          let* old_value = Value.read old_value in
          let+ new_value = Value.read new_value in
          Update { key; old_value; new_value }
      in
      match new_state with
      | None -> ()
      | Some state -> f state event
    in
    Backend.on ?capture ?once ?passive ~prefix callback
  ;;

  let on_insert ?capture ?once ?passive ~key f =
    on ?capture ?once ?passive ~key (fun state ev ->
      match state with
      | Insert { key; value } -> f ~key ~value ev
      | _ -> ())
  ;;

  let on_remove ?capture ?once ?passive ~key f =
    on ?capture ?once ?passive ~key (fun state ev ->
      match state with
      | Remove { key; old_value } -> f ~key ~old_value ev
      | _ -> ())
  ;;

  let on_update ?capture ?once ?passive ~key f =
    on ?capture ?once ?passive ~key (fun state ev ->
      match state with
      | Update { key; old_value; new_value } -> f ~key ~old_value ~new_value ev
      | _ -> ())
  ;;

  module Infix = struct
    let ( ! ) = get
    let ( := ) = set
  end

  include Infix
end
