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

(** The type that describe a storage event (emit by [Local] or [Session]
    storage)*)
type event = Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t

(** The value of a storage event. Used for the function [addEventListener]. *)
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

  (** [make key] build a new reference indexed by [key]. *)
  val make : string -> t

  (** [make_with key value] build a new reference indexed by the given [key] and
      with the given value. *)
  val make_with : string -> Value.t -> t

  (** [make_if_not_exists key value] build a new reference indexed by the given
      [key] and if the value does not exists, it fill it with the given [value]. *)
  val make_if_not_exists : string -> Value.t -> t

  (** [set reference value] set the [value] of the given [reference]. *)
  val set : t -> Value.t -> unit

  (** [get reference] returns the value of the [given] reference. As the backend
      is not controlled by the library, the result is wrapped into an option. *)
  val get : t -> Value.t option

  (** [unset reference] remove the value positionned at the indexed reference. *)
  val unset : t -> unit

  (** {1 Events Handling} *)

  (** [on ?capture ?once ?passive ?prefix] sets up a function that will be
      called whenever the storage change. It return an [event_listener_id] (in
      order to be revoked). A [prefix]. a prefix can be given to filter on keys
      starting only with the prefix. *)
  val on
    :  ?capture:bool
    -> ?once:bool
    -> ?passive:bool
    -> key:string
    -> ((t, Value.t) change
        -> Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t
        -> unit)
    -> Js_of_ocaml.Dom.event_listener_id

  (** A specialized version of {!val:on} only for storage insertion. *)
  val on_insert
    :  ?capture:bool
    -> ?once:bool
    -> ?passive:bool
    -> key:string
    -> (key:t
        -> value:Value.t
        -> Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t
        -> unit)
    -> Js_of_ocaml.Dom.event_listener_id

  (** A specialized version of {!val:on} only for storage deletion (the value of
      the handler contains the deleted value). *)
  val on_remove
    :  ?capture:bool
    -> ?once:bool
    -> ?passive:bool
    -> key:string
    -> (key:t
        -> old_value:Value.t
        -> Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t
        -> unit)
    -> Js_of_ocaml.Dom.event_listener_id

  (** A specialized version of {!val:on} only for storage update. *)
  val on_update
    :  ?capture:bool
    -> ?once:bool
    -> ?passive:bool
    -> key:string
    -> (key:t
        -> old_value:Value.t
        -> new_value:Value.t
        -> Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t
        -> unit)
    -> Js_of_ocaml.Dom.event_listener_id

  (** {2 Lwt events}

      Some event description to deal with [js_of_ocaml-lwt] (using
      [Lwt_js_event]). *)

  (** Lwt version of [on]. *)
  val lwt_on
    :  ?capture:bool
    -> ?passive:bool
    -> key:string
    -> unit
    -> ((t, Value.t) change
       * Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t)
         Lwt.t

  (** Lwt version of [on_insert]. *)
  val lwt_on_insert
    :  ?capture:bool
    -> ?passive:bool
    -> key:string
    -> unit
    -> (t * Value.t * Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t) Lwt.t

  (** Lwt version of [on_remove]. *)
  val lwt_on_remove
    :  ?capture:bool
    -> ?passive:bool
    -> key:string
    -> unit
    -> (t * Value.t * Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t) Lwt.t

  (** Lwt version of [on_update]. *)
  val lwt_on_update
    :  ?capture:bool
    -> ?passive:bool
    -> key:string
    -> unit
    -> (t
       * Value.t
       * [ `Old_value of Value.t ]
       * Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t)
         Lwt.t

  (** {1 Infix Operators} *)

  module Infix : sig
    (** [!reference] is [get reference]. *)
    val ( ! ) : t -> Value.t option

    (** [reference := value] is [set reference value]. *)
    val ( := ) : t -> Value.t -> unit
  end

  include module type of Infix (** @inline*)
end
