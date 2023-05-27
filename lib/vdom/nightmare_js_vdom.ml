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

module Attrib = Attrib

let app ~init ~update ~view () =
  Vdom.app
    ~init
    ~update
    ~view:(fun model -> view model |> Node.remove_node_kind)
    ()
;;

let simple_app ~init ~update ~view () =
  Vdom.simple_app
    ~init
    ~update
    ~view:(fun model -> view model |> Node.remove_node_kind)
    ()
;;

let append_to
  ~id
  ?(not_found =
    fun ~id ->
      let message = "Unable to find the node #" ^ id in
      let () = Nightmare_js.Console.(string error) message in
      Lwt.return_unit)
  callback
  =
  let open Js_browser in
  match Document.get_element_by_id document id with
  | None -> not_found ~id
  | Some root ->
    let open Lwt.Syntax in
    let* app = callback root in
    let () = Vdom_blit.run app |> Vdom_blit.dom |> Element.append_child root in
    Lwt.return_unit
;;

let mount_to ~id ?not_found callback =
  append_to ~id ?not_found (fun element ->
    let () = Js_browser.Element.remove_all_children element in
    callback element)
;;

type ('a, 'msg) attrib = ('a, 'msg) Attrib.t
type ('a, 'msg) node = ('a, 'msg) Node.t

include (Node : module type of Node with type ('a, 'b) t := ('a, 'b) node)
include Endpoint_node
include (Attrib : module type of Attrib with type ('a, 'b) t := ('a, 'b) attrib)
