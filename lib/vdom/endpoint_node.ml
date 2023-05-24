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

let a_of ?anchor ?parameters ?key ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with
    ?anchor
    ?parameters
    endpoint
    (fun target children ->
    let a =
      Attrib.a_href target
      :: (a
           : ([< Nightmare_tyxml.Attrib.Without_source.a ], 'msg) Attrib.t list
           :> ([> Html_types.a_attrib ], 'msg) Attrib.t list)
    in
    Node.a ?key ~a children)
;;

let audio_of ?anchor ?parameters ?key ?srcs ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with
    ?anchor
    ?parameters
    endpoint
    (fun target children -> Node.audio ~src:target ?key ?srcs ~a children)
;;

let base_of ?anchor ?parameters ?key ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with
    ?anchor
    ?parameters
    endpoint
    (fun target ->
    let a =
      Attrib.a_href target
      :: (a
           : ([< Nightmare_tyxml.Attrib.Without_source.base ], 'msg) Attrib.t
             list
           :> ([> Html_types.base_attrib ], 'msg) Attrib.t list)
    in
    Node.base ?key ~a ())
;;

let blockquote_of ?anchor ?parameters ?key ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with
    ?anchor
    ?parameters
    endpoint
    (fun target children ->
    let a =
      Attrib.a_cite target
      :: (a
           : ( [< Nightmare_tyxml.Attrib.Without_source.blockquote ]
             , 'msg )
             Attrib.t
             list
           :> ([> Html_types.blockquote_attrib ], 'msg) Attrib.t list)
    in
    Node.blockquote ?key ~a children)
;;

let del_of ?anchor ?parameters ?key ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with
    ?anchor
    ?parameters
    endpoint
    (fun target children ->
    let a =
      Attrib.a_cite target
      :: (a
           : ([< Nightmare_tyxml.Attrib.Without_source.del ], 'msg) Attrib.t
             list
           :> ([> Html_types.del_attrib ], 'msg) Attrib.t list)
    in
    Node.del ?key ~a children)
;;

let embed_of ?anchor ?parameters ?key ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with
    ?anchor
    ?parameters
    endpoint
    (fun target ->
    let a =
      Attrib.a_src target
      :: (a
           : ([< Nightmare_tyxml.Attrib.Without_source.embed ], 'msg) Attrib.t
             list
           :> ([> Html_types.embed_attrib ], 'msg) Attrib.t list)
    in
    Node.embed ?key ~a ())
;;

let button_of ?anchor ?parameters ?key ?(a = []) endpoint =
  let form_method = Nightmare_service.Endpoint.form_method endpoint in
  Nightmare_service.Endpoint.form_action_with
    ?anchor
    ?parameters
    endpoint
    (fun target children ->
    let a =
      Attrib.a_formaction target
      :: Attrib.a_formmethod form_method
      :: (a
           : ([< Nightmare_tyxml.Attrib.Without_source.button ], 'msg) Attrib.t
             list
           :> ([> Html_types.button_attrib ], 'msg) Attrib.t list)
    in
    Node.button ?key ~a children)
;;

let form_of ?anchor ?parameters ?csrf_token ?key ?(a = []) endpoint =
  let form_method = Nightmare_service.Endpoint.form_method endpoint in
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
            Node.input
              ~a:
                Attrib.
                  [ a_input_type `Hidden
                  ; a_name input_name
                  ; a_value input_value
                  ]
              ()
          in
          x :: children)
        csrf_token
    in
    let a =
      Attrib.a_action target
      :: Attrib.a_method form_method
      :: (a
           : ([< Nightmare_tyxml.Attrib.Without_source.form ], 'msg) Attrib.t
             list
           :> ([> Html_types.form_attrib ], 'msg) Attrib.t list)
    in
    Node.form ?key ~a children)
;;

let iframe_of ?anchor ?parameters ?key ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with
    ?anchor
    ?parameters
    endpoint
    (fun target children ->
    let a =
      Attrib.a_src target
      :: (a
           : ([< Nightmare_tyxml.Attrib.Without_source.iframe ], 'msg) Attrib.t
             list
           :> ([> Html_types.iframe_attrib ], 'msg) Attrib.t list)
    in
    Node.iframe ?key ~a children)
;;

let img_of ~alt ?anchor ?parameters ?key ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with
    ?anchor
    ?parameters
    endpoint
    (fun target -> Node.img ~src:target ~alt ?key ~a ())
;;

let video_of ?anchor ?parameters ?key ?srcs ?(a = []) endpoint =
  Nightmare_service.Endpoint.href_with
    ?anchor
    ?parameters
    endpoint
    (fun target children -> Node.video ~src:target ?key ?srcs ~a children)
;;
