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

(** [Nightmare] is a {i relatively} independent overlay, the [Nightmare_dream]
    package provides the necessary glue to integrate into a web application
    developed with {{:https://aantron.github.io/dream/} Dream}.*)

(** {1 Types}

    Some common type aliases to simplify function signatures. *)

type request = Dream.request
type response = Dream.response
type service = (request, response) Nightmare_service.service
type handler = (request, response) Nightmare_service.handler
type middleware = (request, response) Nightmare_service.middleware

(** {1 Router}

    The [Router] is a [Middleware] (in the sense of [Dream]) that can be easily
    integrated into a middleware pipeline.

    It can, for example, be used in this way:

    {[
      let services = [ my_first_service; my_second_service; my_third_service ]

      let start ?(interface = "0.0.0.0") ~port () =
        Dream.run ~port ~interface
        @@ Dream.logger
        @@ Nightmare_dream.router ~services
      ;;
    ]}

    See {!module:Router} for a more comprehensive example. *)

(** [router ~services fallback request] defines a [Middleware] that tries to
    match a route, and relays on [fallback] if no route is candidate. *)
val router : services:service list -> middleware

module Router = Router

(** {1 Redirection}

    [Nightmare_dream] allows to build redirections (which are [Handler] indexed
    by an [Endpoint]) in order to correctly type the parameters to be provided
    to execute the redirection.

    See {!module:Redirect} for a comprehensive example. *)

(** [redirect_to ?status ?code ?headers ?anchor ?parameters endpoint] returns a
    function that waits to be provisioned by the variables defined by the
    [Endpoint] and a request. *)
val redirect_to
  :  ?status:[< Dream.redirection ]
  -> ?code:int
  -> ?headers:(string * string) list
  -> ?anchor:string
  -> ?parameters:(string * string) list
  -> ( 'scope_
       , [< Nightmare_service.Method.for_link ]
       , 'continuation
       , handler )
       Nightmare_service.Endpoint.wrapped
  -> 'continuation

module Redirect = Redirect
