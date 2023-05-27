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

(** A Dead simple binding for promises. The purpose of this binding is
    essentially to be converted into a promise [Lwt] and should remain internal. *)

(** The liaison is incredibly inspired by these different projects:

    - https://github.com/aantron/promise
    - https://github.com/dbuenzli/brr/blob/master/src/fut.ml#L6
    - https://github.com/mnxn/promise_jsoo

    But its reimplementation aims to be as simple as possible (and as
    comprehensible as possible to the project's maintainers). *)

(** {1 Types} *)

(** The type that describes a promise. *)
type +'a t

(** The type that describes an error. *)
type error

(** {1 Building promises} *)

val pending_with_rejection : unit -> 'a t * ('a -> unit) * (error -> unit)
val pending : unit -> 'a t * ('a -> unit)
val resolved : 'a -> 'a t

(** {1 Acting on promise} *)

val then_ : ('a -> 'b t) -> 'a t -> 'b t
val catch : (error -> 'a t) -> 'a t -> 'a t

(** {1 Lwt interop} *)

val as_lwt : 'a t -> 'a Lwt.t

(** {1 Interfaces} *)

module Functor : Preface.Specs.FUNCTOR with type 'a t = 'a t
module Applicative : Preface.Specs.APPLICATIVE with type 'a t = 'a t
module Monad : Preface.Specs.MONAD with type 'a t = 'a t
