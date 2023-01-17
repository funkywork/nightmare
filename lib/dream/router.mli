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

(** Defines a [Middleware] compatible with [Dream] (and thus [Dream.run] which
    routes a request to a given list of services.

    It can, for example, be used in this way:

    {[
      let services = [ my_first_service; my_second_service; my_third_service ]

      let start ?(interface = "0.0.0.0") ~port () =
        Dream.run ~port ~interface
        @@ Dream.logger
        @@ Dream.sql_pool "sqlite3:db.sqlite"
        @@ Dream.sql_sessions
        @@ Dream.flash
        @@ Nightmare_dream.Router.run ~services
        @@ Dream.not_found
      ;;
    ]}

    Since [Router.run] is [Middleware] (in the sense of [Dream]), not finding a
    candidate route allows a fallback, for example [Dream.not_found]. *)

(** [run ~services fallback request] defines a [Middleware] that tries to match
    a route, and relays on [fallback] if no route is candidate. *)
val run
  :  services:(Dream.request, Dream.response) Nightmare_service.service list
  -> (Dream.request, Dream.response) Nightmare_service.middleware
