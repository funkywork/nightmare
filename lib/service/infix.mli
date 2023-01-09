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

(** Rexported infix operators useful for building services/controllers. *)

(** {2 Endpoint related operators}

    Infix operators related to the manipulation/creation of {!type:Endpoint.t}. *)

(** Since, for {i value restriction} reasons, [endpoints] are often packed into
    a function of type [unit -> endpoint], [~:endpoint] allows the endpoint
    packed into the function to be returned. *)
val ( ~: )
  :  (unit -> ('scope, 'method_, 'a, 'b) Endpoint.t)
  -> ('scope, 'method_, 'a, 'b) Endpoint.t

(** {2 Path related operators}

    Infix operators related to the manipulation/creation of {!type:Path.t}. *)

(** [~/str] create a new path that start with a constant fragment. (see
    {!module:Path} for more information) *)
val ( ~/ ) : string -> ('b, 'b) Path.t

(** [~/var] create a new path that start with a variable fragment. (see
    {!module:Path} for more information) *)
val ( ~/: ) : 'var Path.variable -> ('var -> 'b, 'b) Path.t

(** [path / str] add a constant fragment to a path. (see {!module:Path} for more
    information) *)
val ( / ) : ('a, 'b) Path.t -> string -> ('a, 'b) Path.t

(** [path /: var] add a variable fragment to a path. (see {!module:Path} for
    more information) *)
val ( /: ) : ('a, 'var -> 'b) Path.t -> 'var Path.variable -> ('a, 'b) Path.t
