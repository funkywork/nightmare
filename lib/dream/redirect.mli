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

(** Since [Nightmare_service] [Endpoints] are typed, [Redirect] provides a
    utility for constructing {i type-safe} redirections.

    For example, consider this [Endpoint]:

    {[
      let my_endpoint () =
        let open Nightmare_service.Endpoint in
        get (~/"foo" / "bar" /: int /: string /: bool)
      ;;
    ]}

    It is possible to construct a redirection {i à la Dream} in this way:

    {[
      Nightmare_dream.Redirect.run my_endpoint 10 "foo" false
    ]}

    As the [Endpoint] holds a continuation the parameters to be passed to the
    {!:val:run} function are defined by the type of the [Endpoint].

    In addition, in accordance with the [Dream] documentation, it is possible to
    optionally specify a status, HTTP code and header list, as well as an anchor
    and additional GET parameters.

    Beware, however, that a redirection can only act on an [Endpoint] whose
    method is [GET]. Using [run] on an endpoint attached to another method will
    cause a compile-time error. *)

(** [run ?status ?code ?headers ?anchor ?parameters endpoint] returns a function
    that waits to be provisioned by the variables defined by the [Endpoint] and
    a request. *)
val run
  :  ?status:[< Dream.redirection ]
  -> ?code:int
  -> ?headers:(string * string) list
  -> ?anchor:string
  -> ?parameters:(string * string) list
  -> ( 'scope_
       , [< Nightmare_service.Method.for_link ]
       , 'continuation
       , (Dream.request, Dream.response) Nightmare_service.Handler.t )
       Nightmare_service.Endpoint.wrapped
  -> 'continuation
