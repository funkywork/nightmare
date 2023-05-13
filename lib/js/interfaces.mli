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

(** Generalization of signatures in the manner of the method described in this
    article:
    {{:https://www.craigfe.io/posts/generalised-signatures} Generalised
      signatures}. *)

open Aliases

(** {1 Optional signatures}

    As Js_of_ocaml can handle 3 different types of no value: [option], [optdef]
    and [opt], this is a common interface to handle them uniformly. *)

(** {2 Requirement} *)

module type FOLDABLE_OPTION = sig
  (** A Foldable Option describes how to build a complete interface for optional
      values. *)

  (** the type held by the optional value*)
  type 'a t

  (** [empty] is the empty case of the optional. *)
  val empty : 'a t

  (** [fill x] wrap [x] into the filled case of the optional. *)
  val fill : 'a -> 'a t

  (** [fold empty_case filled_case x] is a visitor on each branch of the
      optional. *)
  val fold : (unit -> 'b) -> ('a -> 'b) -> 'a t -> 'b

  (** Pretty-printer for the optional value. *)
  val pp : (Format.formatter -> 'a -> unit) -> Format.formatter -> 'a t -> unit
end

(** {2 Complete API} *)

module type OPTIONAL = sig
  (** An unified interface for [Stdlib.option], [Js.Opt.t] and [Js.Optdef.t]. *)

  (** {1 Basis API} *)

  include FOLDABLE_OPTION (** @inline *)

  (** [iter f x] performs [f] on the value wrapped into [x]. *)
  val iter : ('a -> unit) -> 'a t -> unit

  (** Equality between optional values. *)
  val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool

  (** [test x] returns [true] if [x] is filled. Otherwise, it returns [false]. *)
  val test : 'a t -> bool

  (** [value ~default x] if [x] is filled, it returns the wrapped value,
      otherwise, it returns [default]. *)
  val value : default:'a -> 'a t -> 'a

  (** Converts an optional into an option. *)
  val to_option : 'a t -> 'a option

  (** Converts an option into an optional. *)
  val from_option : 'a option -> 'a t

  (** Converts an optional into a nullable value. *)
  val to_opt : 'a t -> 'a or_null

  (** Converts a nullable value into an optional. *)
  val from_opt : 'a or_null -> 'a t

  (** Converts an optional into a potentially undefined value. *)
  val to_optdef : 'a t -> 'a or_undefined

  (** Converts a potentially undefined value into an optional. *)
  val from_optdef : 'a or_undefined -> 'a t

  (** {1 Implementation} *)

  module Functor : Preface.Specs.FUNCTOR with type 'a t = 'a t
  module Alt : Preface.Specs.ALT with type 'a t = 'a t

  module Applicative :
    Preface.Specs.Traversable.API_OVER_APPLICATIVE with type 'a t = 'a t

  module Alternative : Preface.Specs.ALTERNATIVE with type 'a t = 'a t
  module Selective : Preface.Specs.SELECTIVE with type 'a t = 'a t
  module Monad : Preface.Specs.Traversable.API_OVER_MONAD with type 'a t = 'a t
  module Monad_plus : Preface.Specs.MONAD_PLUS with type 'a t = 'a t
  module Foldable : Preface.Specs.FOLDABLE with type 'a t = 'a t

  (** {1 Infix} *)

  module Infix : sig
    include Preface.Specs.Functor.INFIX with type 'a t := 'a t (** @inline *)

    include Preface.Specs.Alt.INFIX with type 'a t := 'a t (** @inline *)

    include Preface.Specs.Applicative.INFIX with type 'a t := 'a t
    (** @inline *)

    include Preface.Specs.Alternative.INFIX with type 'a t := 'a t
    (** @inline *)

    include Preface.Specs.Selective.INFIX with type 'a t := 'a t (** @inline *)

    include Preface.Specs.Monad.INFIX with type 'a t := 'a t (** @inline *)

    include Preface.Specs.Monad_plus.INFIX with type 'a t := 'a t (** @inline *)
  end

  include module type of Infix (** @inline *)

  (** {1 Syntax} *)

  module Syntax : sig
    include Preface.Specs.Applicative.SYNTAX with type 'a t := 'a t
    (** @inline *)

    include Preface.Specs.Monad.SYNTAX with type 'a t := 'a t (** @inline *)
  end

  include module type of Syntax (** @inline *)
end

(** {1 Storage signatures}

    Uniform treatment of the two storage modes ([LocalStorage] and
    [SessionStorage]). *)

(** {2 Common types} *)

(** Describes the change of state of a storage. *)
type ('key, 'value) storage_change_state =
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

(** {2 Keys and values}

    Describes a data item that can be serialized (and deserialized) to allow
    arbitrary data storage in a web storage. *)

(** A value that can be injected into a string or projected into a value. *)
module type STORAGE_SERIALIZABLE = sig
  type t

  val write : t -> string
  val read : string -> t option
end

(** The module that describe the prefix/scope of a key. *)
module type PREFIXED_KEY = sig
  val prefix : string
end

(** {2 Storage requirement} *)

module type STORAGE_REQUIREMENT = sig
  val handler : Js_of_ocaml.Dom_html.storage Js_of_ocaml.Js.t or_undefined
end

(** {2 Storage API} *)

module type STORAGE = sig
  (** {1 Types} *)

  (** The type of a [key]. *)
  type key

  (** The type of a [value]. *)
  type value

  (** A [Map] that can be the result of a slice of the storage. *)
  module Map : Map.S with type key = key

  (** A slice of results. *)
  type slice = value Map.t

  (** {1 API} *)

  (** [length ()] return the number of entries stored into the storage. *)
  val length : unit -> int

  (** [get k] return the value indexed by [k] wrapped into an [option]. Returns
      [None] if the value does not exists. *)
  val get : key -> value option

  (** [set k v] stores [v] at the index [k]. *)
  val set : key -> value -> unit

  (** [remove k] delete the value at the index [k]. *)
  val remove : key -> unit

  (** [update f k] allows you to modify an input, passed as an option to a
      function (wrapped in [Some] if it exists, [None] if it doesn't), the
      function returns an [option], too, if it returns [Some] the result is
      modified, if it returns [None] the result is deleted. The final result of
      the function's application is returned.

      - [remove k] = [update (fun _ -> None) k]
      - [set k v] = [update (fun _ -> Some v) k]
      - [match get k with Some x -> set k (x ^ v) then set k v] =
        [update (function Some x -> Some (x ^ v) | None -> Some v)]. *)
  val update : (value option -> value option) -> key -> value option

  (** [clear ()] clear all entries of the storage. *)
  val clear : unit -> unit

  (** [key n] will return the key of the nth [n] entry in the storage.*)
  val key : int -> key option

  (** [nth x] will return the a pair of [key]/[value] of the nth [n] entry in
      the storage. *)
  val nth : int -> (key * value) option

  (** [fold f v] folds every entries of the storage. *)
  val fold : ('acc -> key -> value -> 'acc) -> 'acc -> 'acc

  (** [to_map ()] returns the storage as a [slice] (a [Map] indexed by keys). *)
  val to_map : unit -> slice

  (** [filter p] will returns all entries that satisfies the predicate
      [p key value]. *)
  val filter : (key -> value -> bool) -> slice

  (** {1 Events Handling} *)

  (** [on ?capture ?once ?passive ?prefix] sets up a function that will be
      called whenever the storage change. It return an [event_listener_id] (in
      order to be revoked). A [prefix]. a prefix can be given to filter on keys
      starting only with the prefix. *)
  val on
    :  ?capture:bool
    -> ?once:bool
    -> ?passive:bool
    -> ?prefix:string
    -> ((key, value) storage_change_state
        -> Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t
        -> unit)
    -> Js_of_ocaml.Dom.event_listener_id

  (** A specialized version of {!val:on} only for storage clearing. *)
  val on_clear
    :  ?capture:bool
    -> ?once:bool
    -> ?passive:bool
    -> (Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t -> unit)
    -> Js_of_ocaml.Dom.event_listener_id

  (** A specialized version of {!val:on} only for storage insertion. *)
  val on_insert
    :  ?capture:bool
    -> ?once:bool
    -> ?passive:bool
    -> ?prefix:string
    -> (key:key
        -> value:value
        -> Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t
        -> unit)
    -> Js_of_ocaml.Dom.event_listener_id

  (** A specialized version of {!val:on} only for storage deletion (the value of
      the handler contains the deleted value). *)
  val on_remove
    :  ?capture:bool
    -> ?once:bool
    -> ?passive:bool
    -> ?prefix:string
    -> (key:key
        -> old_value:value
        -> Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t
        -> unit)
    -> Js_of_ocaml.Dom.event_listener_id

  (** A specialized version of {!val:on} only for storage update. *)
  val on_update
    :  ?capture:bool
    -> ?once:bool
    -> ?passive:bool
    -> ?prefix:string
    -> (key:key
        -> old_value:value
        -> new_value:value
        -> Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t
        -> unit)
    -> Js_of_ocaml.Dom.event_listener_id

  (** [event_to_change ev] compute a [(key, value) storage_change_state] from a
      storage event.*)
  val event_to_change
    :  Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t
    -> (key, value) storage_change_state

  (** [event_is_related ev] returns [true] if the event is related to the
      backend, otherwise [false]. *)
  val event_is_related
    :  Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t
    -> bool

  (** {2 Lwt events}

      Some event description to deal with [js_of_ocaml-lwt] (using
      [Lwt_js_event]). *)

  (** Lwt version of [on]. *)
  val lwt_on
    :  ?capture:bool
    -> ?passive:bool
    -> ?prefix:string
    -> unit
    -> ((key, value) storage_change_state
       * Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t)
       Lwt.t

  (** Lwt version of [on_clear]. *)
  val lwt_on_clear
    :  ?capture:bool
    -> ?passive:bool
    -> unit
    -> Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t Lwt.t

  (** Lwt version of [on_insert]. *)
  val lwt_on_insert
    :  ?capture:bool
    -> ?passive:bool
    -> ?prefix:string
    -> unit
    -> (key * value * Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t) Lwt.t

  (** Lwt version of [on_remove]. *)
  val lwt_on_remove
    :  ?capture:bool
    -> ?passive:bool
    -> ?prefix:string
    -> unit
    -> (key * value * Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t) Lwt.t

  (** Lwt version of [on_update]. *)
  val lwt_on_update
    :  ?capture:bool
    -> ?passive:bool
    -> ?prefix:string
    -> unit
    -> (key
       * value
       * [ `Old_value of value ]
       * Js_of_ocaml.Dom_html.storageEvent Js_of_ocaml.Js.t)
       Lwt.t
end
