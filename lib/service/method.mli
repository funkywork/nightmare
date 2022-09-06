(*  MIT License

    Copyright (c) 2022 funkywork

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

(** Deal with common HTTP methods. Associated with a {!type:Path.t}, we can
    describe endpoints to build internal and external links. *)

(** {1 types}

    The set of methods supported by Nightmare are described in polymorphic
    variants that are unified in {!type:t}. This allows methods to be
    intersected, particularly to index certain types more finely. *)

(** See {{:https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods} MDN Web
    documentation} for more information about [HTTP request methods]. *)
type t =
  [ `GET (** Requests a representation of the specified resource. *)
  | `POST (** Submits an entity to the specified resource. *)
  | `PUT
    (** Replaces all current representations of the target resource with the
        request payload. *)
  | `DELETE (** Deletes the specified resource. *)
  | `HEAD (** Like [GET] but without the response body. *)
  | `CONNECT
    (** Makes a tunnel to the server identified by the target resource. *)
  | `OPTIONS (** Describes the communication options for the target resource. *)
  | `TRACE
    (** Performs a message loop-back test along the path to the target resource. *)
  | `PATCH (** Applies partial modifications to a resource. *)
  ]

(** {2 Specialized methods}

    Despite the diversity of HTTP methods, it is not possible to make hyperlinks
    that do more than [GET] and forms can only be [GET] or [POST]. *)

(** A type for the methods accepted by the links. *)
type for_link = [ `GET ]

(** A type for methods accepted as a method of a form. *)
type for_form_action =
  [ `GET
  | `POST
  ]

(** {1 Utils} *)

(** Equality between {!type:t}. *)
val equal : t -> t -> bool

(** Pretty printer for {!type:t}. *)
val pp : Format.formatter -> t -> unit

(** [to_string meth] will render a {!type:t} into an uppercased string. *)
val to_string : t -> string

(** [from_string str] try to find the corresponding method for a given string. *)
val from_string : string -> t option

(** Returns a list of all supported methods. *)
val all : t list
