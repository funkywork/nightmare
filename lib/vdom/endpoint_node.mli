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

(** [audio_of ?anchor ?parameters ?srcs ?a endpoint] generates a function
    expecting the parameters of [endpoint] and returning an HTML element
    [<audio>] (with [src] computed from [endpoint]). *)
val audio_of
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ?key:string
  -> ?srcs:([< Html_types.source ], 'msg) Node.t list
  -> ?a:([< Html_types.audio_attrib ], 'msg) Attrib.t list
  -> ( 'scope
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , ([< Html_types.audio_content_fun ], 'msg) Node.t list
       -> ([> `Audio ], 'msg) Node.t )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [base_of ?anchor ?parameters ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<base>] (with [href]
    computed from [endpoint]). *)
val base_of
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ?key:string
  -> ?a:([< Nightmare_tyxml.Attrib.Without_source.base ], 'msg) Attrib.t list
  -> ( 'scope
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , ([> `Base ], 'msg) Node.t )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [blockquote_of ?anchor ?parameters ?a endpoint] generates a function
    expecting the parameters of [endpoint] and returning an HTML element
    [<blockquote>] (with [cite] computed from [endpoint]). *)
val blockquote_of
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ?key:string
  -> ?a:
       ([< Nightmare_tyxml.Attrib.Without_source.blockquote ], 'msg) Attrib.t
       list
  -> ( 'scope
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , ([< Html_types.blockquote_content_fun ], 'msg) Node.t list
       -> ([> `Blockquote ], 'msg) Node.t )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [video_of ?anchor ?parameters ?srcs ?a endpoint] generates a function
    expecting the parameters of [endpoint] and returning an HTML element
    [<video>] (with [src] computed from [endpoint]). *)
val video_of
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ?key:string
  -> ?srcs:([< Html_types.source ], 'msg) Node.t list
  -> ?a:([< Html_types.video_attrib ], 'msg) Attrib.t list
  -> ( 'scope
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , ([< Html_types.video_content_fun ], 'msg) Node.t list
       -> ([> `Video ], 'msg) Node.t )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation
