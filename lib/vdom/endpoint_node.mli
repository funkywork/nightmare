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

(** [audio_of ?parameters ?srcs ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<audio>] (with [src]
    computed from [endpoint]). *)
val audio_of
  :  ?parameters:(string * string) list
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

(** [base_of ?a endpoint] generates a function expecting the parameters of
    [endpoint] and returning an HTML element [<base>] (with [href] computed from
    [endpoint]). *)
val base_of
  :  ?key:string
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

(** [button_of ?anchor ?parameters ?a endpoint] generates a function expecting
    the parameters of [endpoint] and returning an HTML element [<button>] (with
    [method] and [formaction] computed from [endpoint]). *)
val button_of
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ?key:string
  -> ?a:([< Nightmare_tyxml.Attrib.Without_source.button ], 'msg) Attrib.t list
  -> ( 'scope
     , Nightmare_service.Method.for_form_action
     , 'continuation
     , ([< Html_types.button_content_fun ], 'msg) Node.t list
       -> ([> `Button ], 'msg) Node.t )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [del_of ?anchor ?parameters ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<del>] (with [cite]
    computed from [endpoint]). *)
val del_of
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ?key:string
  -> ?a:([< Nightmare_tyxml.Attrib.Without_source.del ], 'msg) Attrib.t list
  -> ( 'scope
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , ([< Html_types.del_content_fun ], 'msg) Node.t list
       -> ([> `Del ], 'msg) Node.t )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [ins_of ?anchor ?parameters ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<ins>] (with [cite]
    computed from [endpoint]). *)
val ins_of
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ?key:string
  -> ?a:([< Nightmare_tyxml.Attrib.Without_source.ins ], 'msg) Attrib.t list
  -> ( 'scope
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , ([< Html_types.ins_content_fun ], 'msg) Node.t list
       -> ([> `Ins ], 'msg) Node.t )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [embed_of ?parameters ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<embed>] (with [src]
    computed from [endpoint]). *)
val embed_of
  :  ?parameters:(string * string) list
  -> ?key:string
  -> ?a:([< Nightmare_tyxml.Attrib.Without_source.embed ], 'msg) Attrib.t list
  -> ( 'scope
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , ([> `Embed ], 'msg) Node.t )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [form_of ?anchor ?parameters ?csrf_token ?a endpoint] generates a function
    expecting the parameters of [endpoint] and returning an HTML element
    [<form>] (with [method] and [action] computed from [endpoint]). *)
val form_of
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ?csrf_token:string * string
  -> ?key:string
  -> ?a:([< Nightmare_tyxml.Attrib.Without_source.form ], 'msg) Attrib.t list
  -> ( 'scope
     , Nightmare_service.Method.for_form_action
     , 'continuation
     , (Html_types.form_content_fun, 'msg) Node.t list
       -> ([> `Form ], 'msg) Node.t )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [iframe_of ?anchor ?parameters ?a endpoint] generates a function expecting
    the parameters of [endpoint] and returning an HTML element [<iframe>] (with
    [src] computed from [endpoint]). *)
val iframe_of
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ?key:string
  -> ?a:([< Nightmare_tyxml.Attrib.Without_source.iframe ], 'msg) Attrib.t list
  -> ( 'scope
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , ([< Html_types.iframe_content_fun ], 'msg) Node.t list
       -> ([> `Iframe ], 'msg) Node.t )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [img_of ~alt ?parameters ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<img>] (with [src]
    computed from [endpoint]). *)
val img_of
  :  alt:string
  -> ?parameters:(string * string) list
  -> ?key:string
  -> ?a:([< Html_types.img_attrib ], 'msg) Attrib.t list
  -> ( 'scope
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , ([> `Img ], 'msg) Node.t )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [link_of ~rel ?parameters ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<link>] (with [href]
    computed from [endpoint]). *)
val link_of
  :  rel:Html_types.linktypes
  -> ?parameters:(string * string) list
  -> ?key:string
  -> ?a:([< Nightmare_tyxml.Attrib.Without_source.link ], 'msg) Attrib.t list
  -> ( 'scope
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , ([> `Link ], 'msg) Node.t )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [object_of ?parameters ?srcs ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<object>] (with
    [data] computed from [endpoint]). *)
val object_of
  :  ?parameters:(string * string) list
  -> ?key:string
  -> ?a:([< Nightmare_tyxml.Attrib.Without_source.object_ ], 'msg) Attrib.t list
  -> ( 'scope
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , (Html_types.object__content, 'msg) Node.t list
       -> ([> Html_types.object__ ], 'msg) Node.t )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [q_of ?anchor ?parameters ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<q>] (with [cite]
    computed from [endpoint]). *)
val q_of
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ?key:string
  -> ?a:([< Nightmare_tyxml.Attrib.Without_source.q ], 'msg) Attrib.t list
  -> ( 'scope
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , (Html_types.q_content_fun, 'msg) Node.t list -> ([> `Q ], 'msg) Node.t
     )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [script_of ?parameters ?srcs ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<script>] (with
    [src] computed from [endpoint]). *)
val script_of
  :  ?parameters:(string * string) list
  -> ?key:string
  -> ?a:([< Nightmare_tyxml.Attrib.Without_source.script ], 'msg) Attrib.t list
  -> ( 'scope
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , string -> ([> `Script ], 'msg) Node.t )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [source_of ?parameters ?srcs ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<source>] (with
    [src] computed from [endpoint]). *)
val source_of
  :  ?parameters:(string * string) list
  -> ?key:string
  -> ?a:([< Nightmare_tyxml.Attrib.Without_source.source ], 'msg) Attrib.t list
  -> ( 'scope
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , ([> `Source ], 'msg) Node.t )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [video_of ?parameters ?srcs ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<video>] (with [src]
    computed from [endpoint]). *)
val video_of
  :  ?parameters:(string * string) list
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
