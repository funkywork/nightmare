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

(** [app ~init ~update ~view ()] initialize an application that can propagate
    messages and commands. *)
val app
  :  init:'model * 'msg Vdom.Cmd.t
  -> update:('model -> 'msg -> 'model * 'msg Vdom.Cmd.t)
  -> view:('model -> ('kind, 'msg) Node.t)
  -> unit
  -> ('model, 'msg) Vdom.app

(** [simple_app ~init ~update ~view ()] initialize an application that can
    propagate messages. *)
val simple_app
  :  init:'model
  -> update:('model -> 'msg -> 'model)
  -> view:('model -> ('kind, 'msg) Node.t)
  -> unit
  -> ('model, 'msg) Vdom.app

(** {1 Mounting an application} *)

(** [append_to ~id ~not_found f] will append the application returned by [f]
    into the element referenced by [id]. If the [element] does not exists,
    [not_found] will be fired. *)
val append_to
  :  id:string
  -> ?not_found:(id:string -> unit Lwt.t)
  -> (Js_browser.Element.t -> ('model, 'msg) Vdom.app Lwt.t)
  -> unit Lwt.t

(** [mount_to ~id ~not_found f] same of [append_to] but it removes all children
    of the target. *)
val mount_to
  :  id:string
  -> ?not_found:(id:string -> unit Lwt.t)
  -> (Js_browser.Element.t -> ('model, 'msg) Vdom.app Lwt.t)
  -> unit Lwt.t

(** {1 Types} *)

(** {2 Html elements} *)

(** The type describing an attribute of an HTML node. The first parameter is a
    ghost type and the second is used to propagate messages from the virtual
    DOM.*)
type ('a, 'msg) attrib = ('a, 'msg) Attrib.t

(** The type describing an Html Node. *)
type ('a, 'msg) node = ('a, 'msg) Node.t

(** {1 Html Elements} *)

include module type of Node with type ('a, 'b) t := ('a, 'b) node (** @inline *)

(** {2 Html Elements connected to endpoints} *)

include module type of Endpoint_node (** @inline*)

(** {1 Attributes} *)

include module type of Attrib with type ('a, 'b) t := ('a, 'b) attrib
(** @inline*)

(** {1 Internal modules}

    Even if all functions are re-exported in this module, the auxiliary modules
    are accessible. *)

module Attrib = Attrib
