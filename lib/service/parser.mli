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

(** Some quickly written parsers to process data of different types. *)

module Href : sig
  (** Allows you to extract different fragments of an internal URL (without the
      scheme and protocol) represented as the [href] parameter of a link. Either
      respecting the [fragments?query_string#anchor] schema. *)

  (** A parsed [href]. *)
  type t

  (** Builds an internal URL with an optional query string and an optional
      anchor. *)
  val make : ?query_string:string -> ?anchor:string -> string list -> t

  (** Return the [fragments] part of the [Href]. *)
  val fragments : t -> string list

  (** Return the [query_string] part of the [Href]. *)
  val query_string : t -> string option

  (** Return the [anchor] part of the [Href]. *)
  val anchor : t -> string option

  (** Produce a {{!type:t} Href.t} from a string. The function will never fail
      since if an internal URL is not valid, it will return an empty fragment
      and anchor and query string at None. *)
  val from_string : string -> t

  (** Equality between internal URL (mostly used for test). *)
  val equal : t -> t -> bool

  (** A pretty-printer (mostly used for test). *)
  val pp : Format.formatter -> t -> unit
end
