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

type t = ..
type t += Unknown

type desc =
  | E :
      { (* The definition of coersion function are existentially packed *)
        id : string
      ; title : string
      ; description : string
      ; pp : Format.formatter -> 'a -> unit
      ; read : t -> 'a option
      ; write : 'a -> t
      ; equal : t -> t -> bool
      }
      -> desc

type registered =
  { id : string
  ; title : string
  ; description : string
  ; pp : Format.formatter -> t -> unit
  ; equal : t -> t -> bool
  }

let registered = ref []

let register' ~id ~title ~description ~pp read write equal =
  let equal a b =
    match read a, read b with
    | Some a, Some b -> equal a b
    | _ -> false
  in
  let desc = E { id; title; description; pp; read; write; equal } in
  let _ = registered := desc :: !registered in
  desc
;;

let pp_unkown ppf () = Format.fprintf ppf "Unknown error"

let unknown_desc =
  register'
    ~id:"nightmare.unknown"
    ~title:"Unknown error"
    ~description:"An unknown error that can be used as a neutral element"
    ~pp:pp_unkown
    (function
     | Unknown -> Some ()
     | _ -> None)
    (fun () -> Unknown)
    (fun () () -> true)
;;

let register ~id ~title ~description ~pp read write equal =
  register' ~id ~title ~description ~pp read write equal |> ignore
;;

let get_repr error =
  let error, E { pp; id; title; description; read; equal; _ } =
    List.find_opt
      (function
       | E { read; _ } -> Option.is_some (read error))
      !registered
    |> Option.fold ~none:(Unknown, unknown_desc) ~some:(fun desc -> error, desc)
  in
  let pp ppf error =
    match read error with
    | None -> pp_unkown ppf ()
    | Some params -> pp ppf params
  in
  error, { id; title; description; pp; equal }
;;

let handle error f =
  let new_error, desc = get_repr error in
  f desc new_error
;;

let equal a b =
  let _, { equal; _ } = get_repr a in
  equal a b
;;

let pp ppf err =
  let _, { pp; _ } = get_repr err in
  pp ppf err
;;

(* Internal and predefined errors *)

type t += With_message of { message : string }

let () =
  register
    ~id:"nightmare.with_message"
    ~title:"Labelled error"
    ~description:"An error with a message"
    ~pp:(fun ppf -> Format.fprintf ppf "message: %s")
    (function
     | With_message { message } -> Some message
     | _ -> None)
    (fun message -> With_message { message })
    String.equal
;;
