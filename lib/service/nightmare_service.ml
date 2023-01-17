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

type method_ = Method.t
type ('continuation, 'witness) path = ('continuation, 'witness) Path.t

type ('continuation, 'witness) wrapped_path =
  ('continuation, 'witness) Path.wrapped

type ('scope, 'method_, 'continuation, 'witness) endpoint =
  ('scope, 'method_, 'continuation, 'witness) Endpoint.t

type ('scope, 'method_, 'continuation, 'witness) wrapped_endpoint =
  ('scope, 'method_, 'continuation, 'witness) Endpoint.wrapped

type ('request, 'response) handler = ('request, 'response) Handler.t
type ('request, 'response) middleware = ('request, 'response) Middleware.t
type ('request, 'response) service = ('request, 'response) Service.t

module Path = Path
module Endpoint = Endpoint
module Parser = Parser
module Method = Method
module Handler = Handler
module Middleware = Middleware
module Service = Service
module Signatures = Signatures
