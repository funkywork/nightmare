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

let a_of ?anchor ?parameters ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with
    ?anchor
    ?parameters
    endpoint
    (fun target children ->
    let a =
      Tyxml.Html.a_href target
      :: (a
           : [< Attrib.Without_source.a ] Tyxml.Html.attrib list
           :> [> Html_types.a_attrib ] Tyxml.Html.attrib list)
    in
    Tyxml.Html.a ~a children)
;;

let audio_of ?anchor ?parameters ?srcs ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with
    ?anchor
    ?parameters
    endpoint
    (fun target children -> Tyxml.Html.audio ~src:target ?srcs ~a children)
;;

let base_of ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with endpoint (fun target ->
    let a =
      Tyxml.Html.a_href target
      :: (a
           : [< Attrib.Without_source.base ] Tyxml.Html.attrib list
           :> [> Html_types.base_attrib ] Tyxml.Html.attrib list)
    in
    Tyxml.Html.base ~a ())
;;

let blockquote_of ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with endpoint (fun target children ->
    let a =
      Tyxml.Html.a_cite target
      :: (a
           : [< Attrib.Without_source.blockquote ] Tyxml.Html.attrib list
           :> [> Html_types.blockquote_attrib ] Tyxml.Html.attrib list)
    in
    Tyxml.Html.blockquote ~a children)
;;

let del_of ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with endpoint (fun target children ->
    let a =
      Tyxml.Html.a_cite target
      :: (a
           : [< Attrib.Without_source.del ] Tyxml.Html.attrib list
           :> [> Html_types.del_attrib ] Tyxml.Html.attrib list)
    in
    Tyxml.Html.del ~a children)
;;

let embed_of ?parameters ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with ?parameters endpoint (fun target ->
    let a =
      Tyxml.Html.a_src target
      :: (a
           : [< Attrib.Without_source.embed ] Tyxml.Html.attrib list
           :> [> Html_types.embed_attrib ] Tyxml.Html.attrib list)
    in
    Tyxml.Html.embed ~a ())
;;

let endpoint_method_to_tyxml_method = function
  | `GET -> `Get
  | `POST -> `Post
;;

let button_of ?anchor ?parameters ?(a = []) endpoint =
  let form_method =
    Nightmare_service.Endpoint.form_method endpoint
    |> endpoint_method_to_tyxml_method
  in
  Nightmare_service.Endpoint.form_action_with
    ?anchor
    ?parameters
    endpoint
    (fun target children ->
    let a =
      Tyxml.Html.a_formaction target
      :: Tyxml.Html.a_method form_method
      :: (a
           : [< Attrib.Without_source.button ] Tyxml.Html.attrib list
           :> [> Html_types.button_attrib ] Tyxml.Html.attrib list)
    in
    Tyxml.Html.button ~a children)
;;

let form_of ?anchor ?parameters ?csrf_token ?(a = []) endpoint =
  let form_method =
    Nightmare_service.Endpoint.form_method endpoint
    |> endpoint_method_to_tyxml_method
  in
  Nightmare_service.Endpoint.form_action_with
    ?anchor
    ?parameters
    endpoint
    (fun target children ->
    let children =
      Option.fold
        ~none:children
        ~some:(fun (input_name, input_value) ->
          let x =
            Tyxml.Html.(
              input
                ~a:
                  [ a_input_type `Hidden
                  ; a_name input_name
                  ; a_value input_value
                  ])
              ()
          in
          x :: children)
        csrf_token
    in
    let a =
      Tyxml.Html.a_action target
      :: Tyxml.Html.a_method form_method
      :: (a
           : [< Attrib.Without_source.form ] Tyxml.Html.attrib list
           :> [> Html_types.form_attrib ] Tyxml.Html.attrib list)
    in
    Tyxml.Html.form ~a children)
;;

let iframe_of ?anchor ?parameters ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with
    ?anchor
    ?parameters
    endpoint
    (fun target children ->
    let a =
      Tyxml.Html.a_src target
      :: (a
           : [< Attrib.Without_source.iframe ] Tyxml.Html.attrib list
           :> [> Html_types.iframe_attrib ] Tyxml.Html.attrib list)
    in
    Tyxml.Html.iframe ~a children)
;;

let img_of ?parameters ?alt ?(a = []) endpoint =
  let alt = Option.value ~default:"" alt in
  Nightmare_service.Endpoint.href_with ?parameters endpoint (fun target ->
    Tyxml.Html.img ~a ~src:target ~alt ())
;;

let link_of ?parameters ~rel ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with ?parameters endpoint (fun target ->
    Tyxml.Html.link ~a ~rel ~href:target ())
;;

let object_of ?parameters ?(a = []) ?object_params endpoint =
  Nightmare_service.Endpoint.href_with
    ?parameters
    endpoint
    (fun target children ->
    let a =
      Tyxml.Html.a_data target
      :: (a
           : [< Attrib.Without_source.object_ ] Tyxml.Html.attrib list
           :> [> Html_types.object__attrib ] Tyxml.Html.attrib list)
    in
    Tyxml.Html.object_ ?params:object_params ~a children)
;;

let script_of ?parameters ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with
    ?parameters
    endpoint
    (fun target children ->
    let a =
      Tyxml.Html.a_src target
      :: (a
           : [< Attrib.Without_source.script ] Tyxml.Html.attrib list
           :> [> Html_types.script_attrib ] Tyxml.Html.attrib list)
    in
    Tyxml.Html.script ~a children)
;;

let source_of ?parameters ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with ?parameters endpoint (fun target ->
    let a =
      Tyxml.Html.a_src target
      :: (a
           : [< Attrib.Without_source.source ] Tyxml.Html.attrib list
           :> [> Html_types.source_attrib ] Tyxml.Html.attrib list)
    in
    Tyxml.Html.source ~a ())
;;

let video_of ?anchor ?parameters ?srcs ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with
    ?anchor
    ?parameters
    endpoint
    (fun target children -> Tyxml.Html.video ~src:target ?srcs ~a children)
;;

module Attrib = Attrib
