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

(** JavaScript's usual stream binding. *)

open Js_of_ocaml

module Reader : sig
  (** A [Reader] represents a default reader that can be used to read stream
      data supplied from a network (such as a fetch request). *)

  type 'a t = 'a Bindings.readable_stream_default_reader Js.t

  val is_closed : 'a t -> bool
  val cancel : ?reason:string -> 'a t -> unit Lwt.t
  val close : 'a t -> unit Lwt.t
  val read : 'a t -> (bool * 'a) Lwt.t
  val read_string : 'a t -> (bool * string) Lwt.t
  val release_lock : 'a t -> unit
end

module Readable : sig
  (** The ReadableStream interface of the Streams API represents a readable
      stream of byte data. The Fetch API offers a concrete instance of a
      ReadableStream through the body property of a Response object. *)

  type 'a t = 'a Bindings.readable_stream Js.t

  val is_locked : 'a t -> bool
  val cancel : ?reason:string -> 'a t -> unit Lwt.t
  val get_reader : 'a t -> 'a Reader.t
end
