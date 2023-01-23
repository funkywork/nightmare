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

(** Some utilities to comfortably use [Nightmare] tools with the
    {{:https://ocsigen.org/tyxml/latest/manual/intro} TyXML} library
    ({{:https://ocsigen.org/tyxml/latest/api/Tyxml.Html} Html part}). *)

(** {1 Endpoint instead of Uri}

    a large proportion of HTML elements reference URLs, here is a list of hooks
    that use {!type:Nightmare.Endpoint.t} instead of simple strings. Usually,
    the [TyXML]'s corresponding element is suffixed by [_of].

    {2 Example}

    Here is an example that use {!val:a_of}, let's look at these 3 endpoints:

    {[
      open Nightmare_service.Endpoint

      let home () = get ~/"home"
      let user () = get (~/"user" / "name" /: string)
      let repo () = outer get "https://github.com" (~/:string /: string)
    ]}

    We can imagine this fancy footer that takes advantage of our three endpoints
    to build a tree of links:

    {[
      let footer_block =
        let open Tyxml.Html in
        footer
          ~a:[ a_class [ "footer" ] ]
          [ p [ txt "Here are some links:" ]
          ; ul
              [ li [ a_of home ~anchor:"content" [ txt "Go to the homepage" ] ]
              ; li [ a_of user "grm" [ txt "Visit GRM profile" ] ]
              ; li [ a_of user "xvw" [ txt "Visit XVW profile" ] ]
              ; li [ a_of user "xml" [ txt "Visit XHTMLBoy profile" ] ]
              ; li
                  [ a_of
                      ~a:[ a_target "_blank" ]
                      repo
                      "funkywork"
                      "nightmare"
                      [ txt "Visit Nightmare repository" ]
                  ]
              ]
          ]
      ;;
    ]}

    Overall, the API is very similar to the [Tyxml.Html.a] function and
    attributes (except for those derived from the endpoint like [href] or
    [src].) can still be passed to the [a_of] function. *)

(** {2 Elements} *)

(** [a_of ?anchor ?parameters ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<a>] (with [href]
    computed from [endpoint]). *)
val a_of
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ?a:Attrib.a Tyxml.Html.attrib list
  -> ( _
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , 'b Tyxml.Html.elt list -> [> 'b Html_types.a ] Tyxml.Html.elt )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [base_of ?anchor ?parameters ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<base>]. (with
    [href] computed from [endpoint]) *)
val base_of
  :  ?a:Attrib.base Tyxml.Html.attrib list
  -> ( 'scope_
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , [> Html_types.base ] Tyxml.Html.elt )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [embed_of ?anchor ?parameters ?a endpoint] generates a function expecting
    the parameters of [endpoint] and returning an HTML element [<embed>]. (with
    [src] computed from [endpoint]) *)
val embed_of
  :  ?parameters:(string * string) list
  -> ?a:Attrib.embed Tyxml.Html.attrib list
  -> ( 'scope_
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , [> Html_types.embed ] Tyxml.Html.elt )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [form_of ?anchor ?parameters ?csrf_token ?a endpoint] generates a function
    expecting the parameters of [endpoint] and returning an HTML element
    [<form>]. (with [action] and [method] computed from [endpoint]). If a
    [csrf_token] is provided, it include, in the form an hidden input with the
    first of element as name and the second one as value. *)
val form_of
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ?csrf_token:string * string
  -> ?a:Attrib.form Tyxml.Html.attrib list
  -> ( 'scope_
     , Nightmare_service.Method.for_form_action
     , 'continuation
     , Html_types.form_content_fun Tyxml.Html.elt list
       -> [> Html_types.form ] Tyxml.Html.elt )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [iframe_of ?anchor ?parameters ?a endpoint] generates a function expecting
    the parameters of [endpoint] and returning an HTML element [<iframe>] (with
    [src] computed from [endpoint]). *)
val iframe_of
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ?a:Attrib.iframe Tyxml.Html.attrib list
  -> ( _
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , Html_types.iframe_content_fun Tyxml.Html.elt list
       -> [> Html_types.iframe ] Tyxml.Html.elt )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [img_of ?parameters ?alt ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<img>] (with [src]
    computed from [endpoint]). *)
val img_of
  :  ?parameters:(string * string) list
  -> ?alt:string
  -> ?a:Html_types.img_attrib Tyxml.Html.attrib list
  -> ( _
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , [> Html_types.img ] Tyxml.Html.elt )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [link_of ?parameters ~rel ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<link>] (with [href]
    computed from [endpoint]). *)
val link_of
  :  ?parameters:(string * string) list
  -> rel:Html_types.linktypes
  -> ?a:Attrib.link Tyxml.Html.attrib list
  -> ( _
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , [> Html_types.link ] Tyxml.Html.elt )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [object_of ?parameters ?a ?object_param endpoint] generates a function
    expecting the parameters of [endpoint] and returning an HTML element
    [<object>] (with [data] computed from [endpoint]). *)
val object_of
  :  ?parameters:(string * string) list
  -> ?a:Attrib.object_ Tyxml.Html.attrib list
  -> ?object_params:Html_types.param Tyxml.Html.elt list
  -> ( _
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , Html_types.object__content Tyxml.Html.elt list
       -> [> Html_types.object__ ] Tyxml.Html.elt )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [script_of ?parameters ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<script>] (with
    [src] computed from [endpoint]). *)
val script_of
  :  ?parameters:(string * string) list
  -> ?a:Attrib.script Tyxml.Html.attrib list
  -> ( _
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , Html_types.script_content_fun Tyxml.Html.elt
       -> [> Html_types.script ] Tyxml.Html.elt )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** [source_of ?parameters ?a endpoint] generates a function expecting the
    parameters of [endpoint] and returning an HTML element [<source>] (with
    [src] computed from [endpoint]). *)
val source_of
  :  ?parameters:(string * string) list
  -> ?a:Attrib.source Tyxml.Html.attrib list
  -> ( _
     , [< Nightmare_service.Method.for_link ]
     , 'continuation
     , [> Html_types.source ] Tyxml.Html.elt )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation

(** {1 Hooked attributes} *)

module Attrib = Attrib
