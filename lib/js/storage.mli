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

(** {1 Common types} *)

(** Describes the change of state of a storage. Mostly used for event handling. *)
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

(** {1 Storage Event} *)

type event = Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t

val event : event Js_of_ocaml.Dom.Event.typ

(** {1 Common signatures} *)

module type REQUIREMENT = Interfaces.STORAGE_REQUIREMENT
module type S = Interfaces.STORAGE

(** {1 Exception}

    Exceptions are not supposed to appear, they are only present to make the API
    complete. *)

(** In the age of our modern browsers, this exception should never be launched. *)
exception Not_supported

(** {1 Create a storage} *)

module Make (Req : REQUIREMENT) :
  S with type key = string and type value = string

(** {1 Predefined storages} *)

module Local : S with type key = string and type value = string
module Session : S with type key = string and type value = string

(** {1 References}

    A reference is similar to OCaml's [ref] except that it is persisted in an
    associated backend. ([Local] or [Session]), however, as deletion of storage
    is not controllable, they always return options. A key is prefixed, which is
    a poor way of making a scope. *)

module type VALUE = Interfaces.STORAGE_SERIALIZABLE
module type KEY = Interfaces.PREFIXED_KEY

(** A functor to build particular kind of references. *)
module Ref
  (Backend : S with type key = string and type value = string)
  (Key : KEY)
  (Value : VALUE) : sig
  (** The type that describe a Ref. *)
  type t

  val make : string -> t
  val make_with : string -> Value.t -> t
  val make_if_not_exists : string -> Value.t -> t
  val set : t -> Value.t -> unit
  val get : t -> Value.t option

  module Infix : sig
    val ( ! ) : t -> Value.t option
    val ( := ) : t -> Value.t -> unit
  end

  include module type of Infix
end
