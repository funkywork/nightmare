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

(** The Blob object represents a blob, which is a file-like object of immutable,
    raw data; they can be read as text or binary data, or converted into a
    ReadableStream so its methods can be used for processing the data. *)

open Js_of_ocaml

type t = Bindings.blob Js.t

val size : t -> int
val content_type : t -> string
val array_buffer : t -> Typed_array.arrayBuffer Js.t Lwt.t
val slice : ?content_type:string -> start:int -> stop:int -> t -> t
val stream : t -> Typed_array.uint8Array Js.t Stream.Readable.t
val text : t -> string Lwt.t
val make : ?content_type:string -> string list -> t
