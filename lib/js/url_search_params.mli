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

(** The [Url_search_params] interface defines utility methods to work with the
    query string of a URL. *)

open Js_of_ocaml

(** {1 Types} *)

type t = Bindings.url_search_params Js.t

(** {1 Constructing Url Search Params object} *)

(** [make query_string] build a new [Url Search Params] object. *)
val make : string -> t

(** {1 Acting on Url Search Params} *)

val append : t -> key:string -> value:string -> t
val delete : t -> key:string -> t
val set : t -> key:string -> value:string -> t
val get : t -> key:string -> string option
val get_all : t -> key:string -> string list
val has : t -> key:string -> bool
val to_string : t -> string
val sort : t -> t
