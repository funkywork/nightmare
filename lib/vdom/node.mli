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
type (_, 'msg) t

(** Describes a node that take a list of attributes and a list of nodes (as
    children).

    - ['attrib] is a phantom type that fixes available attributes
    - ['children] is a phantom type that fixes available children
    - ['result] is a phantom type that gives the kind of the generated node
    - ['msg] is the message propagated by the VDom.
    - [?key] is the key for the VDom diffing
    - [?a] is the list of the attributes *)
type ('attrib, 'children, 'result, 'msg) star =
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
    star

(** [a ?key ?a children] produce a [<a>] element. *)
val a : ([< Html_types.a_attrib ], 'a, 'a Html_types.a, 'msg) star
