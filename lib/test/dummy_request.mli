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

(** Dummy_request is a module that mimics a pseudo-http context that potentially
    simulates the application of middleware. The dummy request is an association
    between environment variables and a status that can be [ok content],
    [redirect url] or [error message]. *)

(** {1 Types} *)

(** A dummy request (a set of environment variables and a status)*)
type t

(** An pseudo HTTP status.*)
type status =
  | Ok of string
  | Redirect of string
  | Error of string

(** {1 Construction} *)

(** [make_ok ?env content] will produce a dummy request that is [ok content]. *)
val make_ok : ?env:(string * string) list -> string -> t

(** [make_error ?env message] will produce a dummy request that is
    [error message]. *)
val make_error : ?env:(string * string) list -> string -> t

(** [make_redirect ?env message] will produce a dummy request that is
    [redirect url]. *)
val make_redirect : ?env:(string * string) list -> string -> t

(** {1 Accessors} *)

(** [status_of request] get the status of a request. *)
val status_of : t -> status

(** {1 Update} *)

(** [ok content request] will replace the status of the given request to
    [ok content]. *)
val ok : string -> t -> t

(** [error message request] will replace the status of the given request to
    [error message]. *)
val error : string -> t -> t

(** [redirect url request] will replace the status of the given request to
    [redirect url]. *)
val redirect : string -> t -> t

(** {1 Environment Variables} *)

(** [get_var ~key request] try to find the key into the request. *)
val get_var : key:string -> t -> string option

(** [add_var ~key ~value request] add a variable into the request. *)
val add_var : key:string -> value:string -> t -> t

(** [remove_var ~key  request] remove a variable into the request. *)
val remove_var : key:string -> t -> t

(** [clean_var request] remove all variables into the request. *)
val clean_var : t -> t

(** {1 Helpers} *)

val pp : Format.formatter -> t -> unit
val equal : t -> t -> bool
val testable : t Alcotest.testable
