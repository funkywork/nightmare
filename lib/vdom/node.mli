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

(** Describes HTML nodes *)

(** An attribute has the type [('kind, 'message) t], the ['kind] is a phantom
    type to allows only valid nodes in node children. *)
type (_, +'msg) t

(** For the following types, the conventions used are

    - ['attrib] is a phantom type that fixes available attributes
    - ['children] is a phantom type that fixes available children
    - ['result] is a phantom type that gives the kind of the generated node
    - ['msg] is the message propagated by the VDom.
    - [?key] is the key for the VDom diffing
    - [?a] is the list of the attributes *)

(** Describes a node that take a list of attributes and have no children. *)
type ('attrib, 'result, 'msg) leaf =
  ?key:string -> ?a:('attrib, 'msg) Attrib.t list -> unit -> ('result, 'msg) t

(** Describes a node that take a just one children. *)
type ('attrib, 'children, 'result, 'msg) one =
  ?key:string -> ?a:('attrib, 'msg) Attrib.t list -> unit -> ('result, 'msg) t

(** Describes a node that take a list of attributes and a list of nodes (as
    children). *)
type ('attrib, 'children, 'result, 'msg) many =
  ?key:string
  -> ?a:('attrib, 'msg) Attrib.t list
  -> ('children, 'msg) t list
  -> ('result, 'msg) t

(** [txt ?key value] wrap [value] into a text node (pcdata). *)
val txt : ?key:string -> string -> ([> Html_types.txt ], 'msg) t

(** [div ?key ?a children] produce a [<div>] element. *)
val div
  : ( [< Html_types.div_attrib ]
    , [< Html_types.div_content_fun ]
    , [> `Div ]
    , 'msg )
    many

(** [a ?key ?a children] produce a [<a>] element. *)
val a : ([< Html_types.a_attrib ], 'a, 'a Html_types.a, 'msg) many

(** [abbr ?key ?a children] produce a [<abbr>] element. *)
val abbr
  : ( [< Html_types.abbr_attrib ]
    , [< Html_types.abbr_content_fun ]
    , [> `Abbr ]
    , 'msg )
    many

(** [address ?key ?a children] produce a [<address>] element. *)
val address
  : ( [< Html_types.address_attrib ]
    , [< Html_types.address_content_fun ]
    , [> `Address ]
    , 'msg )
    many

(** [area ?key ?a ()] produce a [<area>] element. *)
val area : ([< Html_types.area_attrib ], [> `Area ], 'msg) leaf

(** [article ?key ?a children] produce a [<article>] element. *)
val article
  : ( [< Html_types.article_attrib ]
    , [< Html_types.article_content_fun ]
    , [> `Article ]
    , 'msg )
    many

(** [aside ?key ?a children] produce a [<aside>] element. *)
val aside
  : ( [< Html_types.aside_attrib ]
    , [< Html_types.aside_content_fun ]
    , [> `Aside ]
    , 'msg )
    many

(** [audio ?key ?srcs ?a children] produce a [<audio>] element. *)
val audio
  :  ?src:string
  -> ?srcs:([< Html_types.source ], 'msg) t list
  -> ( [< Html_types.audio_attrib ]
     , [< Html_types.audio_content_fun ]
     , [> `Audio ]
     , 'msg )
     many

(** [b ?key ?a children] produce a [<b>] element. *)
val b
  : ( [< Html_types.b_attrib ]
    , [< Html_types.b_content_fun ]
    , [> `B ]
    , 'msg )
    many

(** [base ?key ?a ()] produce a [<base>] element. *)
val base : ([< Html_types.base_attrib ], [> `Base ], 'msg) leaf

(** [bdi ~dir ?key ?a children] produce a [<bdi>] element. *)
val bdi
  :  dir:[< `Ltr | `Rtl ]
  -> ( [< Html_types.bdo_attrib > `Dir ]
     , [< Html_types.bdo_content_fun ]
     , [> `Bdo ]
     , 'msg )
     many
(* Using `Bdo related stuff is voluntary. *)

(** [bdo ~dir ?key ?a children] produce a [<bdo>] element. *)
val bdo
  :  dir:[< `Ltr | `Rtl ]
  -> ( [< Html_types.bdo_attrib > `Dir ]
     , [< Html_types.bdo_content_fun ]
     , [> `Bdo ]
     , 'msg )
     many

(** [blockquote ?key ?a children] produce a [<blockquote>] element. *)
val blockquote
  : ( [< Html_types.blockquote_attrib ]
    , [< Html_types.blockquote_content_fun ]
    , [> `Blockquote ]
    , 'msg )
    many

(** [video ?key ?srcs ?a children] produce a [<video>] element. *)
val video
  :  ?src:string
  -> ?srcs:([< Html_types.source ], 'msg) t list
  -> ( [< Html_types.video_attrib ]
     , [< Html_types.video_content_fun ]
     , [> `Video ]
     , 'msg )
     many

(** {1 Node helpers} *)

val remove_node_kind : ('a, 'msg) t -> 'msg Vdom.vdom
