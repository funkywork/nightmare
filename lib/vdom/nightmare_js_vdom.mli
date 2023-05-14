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

(** A library to glue together [Nightmare], [Tyxml] and [ocaml-vdom]. While
    having some differences, the API for describing nodes and attributes is very
    similar to Tyxml (and shares many signatures), *)

(** {1 Types} *)

(** The type describing an attribute of an HTML node. The first parameter is a
    ghost type and the second is used to propagate messages from the virtual
    DOM.*)
type (+'a, +'msg) attrib = ('a, 'msg) Attrib.t

(** {1 Attributes} *)

include module type of Attrib with type (+'a, +'b) t := ('a, 'b) attrib
(** @inline*)

(** {1 Internal modules}

    Even if all functions are re-exported in this module, the auxiliary modules
    are accessible. *)

module Types = Types
module Attrib = Attrib
