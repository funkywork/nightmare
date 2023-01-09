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

(** [Nightmare_service] is a library that embeds everything that concerns the
    definition of services/controllers. *)

(** {1 Types aliases} *)

(** [method_] is an alias for {!type:Method.t}. *)
type method_ = Method.t

(** [path] is an alias for {!type:Path.t}. *)
type ('continuation, 'witness) path = ('continuation, 'witness) Path.t

(** [wrapped_path] is an alias for {!type:Path.wrapped}. *)
type ('continuation, 'witness) wrapped_path =
  ('continuation, 'witness) Path.wrapped

(** [endpoint] is an alias for {!type:Endpoint.t}. *)
type ('scope, 'method_, 'continuation, 'witness) endpoint =
  ('scope, 'method_, 'continuation, 'witness) Endpoint.t

(** [wrapped_endpoint] is an alias for {!type:Endpoint.wrapped}. *)
type ('scope, 'method_, 'continuation, 'witness) wrapped_endpoint =
  ('scope, 'method_, 'continuation, 'witness) Endpoint.wrapped

(** {1 Infix operators} *)

include module type of Infix (** @inline *)

(** {1 Modules}

    Modules describing the different components of a service/controller (its
    path, an endpoint, supported HTTP methods) and other utilities. *)

module Path = Path
module Endpoint = Endpoint
module Parser = Parser
module Method = Method
module Infix = Infix

(** {1 Signatures}

    Signatures of modules that can be used as parameters of functors or to type
    first class modules. *)

module Signatures = Signatures
