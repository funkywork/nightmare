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

(** Describes HTML nodes using Nightmare [Endpoints] to provision various
    sources. This is the [ocaml-vdom] version of {!module:Nightmare_tyxml}*)

(** [a_of ?anchor ?parameters ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<a>] (with [href]
    computed from [endpoint]). *)
val a_of
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ?key:string
  -> ?a:([< Nightmare_tyxml.Attrib.Without_source.a ], 'msg) Attrib.t list
  -> ( 'scope
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , ('children, 'msg) Node.t list -> ('children Html_types.a, 'msg) Node.t
     )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation
