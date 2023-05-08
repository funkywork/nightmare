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
