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

(** Describes HTML nodes using types from TyXML. *)

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
  ?key:string
  -> ?a:('attrib, 'msg) Attrib.t list
  -> 'children
  -> ('result, 'msg) t

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

(** [br ?key ?a ()] produce a [<br>] element. *)
val br : ([< Html_types.br_attrib ], [> `Br ], 'msg) leaf

(** [hr ?key ?a ()] produce a [<hr>] element. *)
val hr : ([< Html_types.hr_attrib ], [> `Hr ], 'msg) leaf

(** [button ?key ?a children] produce a [<button>] element. *)
val button
  : ( [< Html_types.button_attrib ]
    , [< Html_types.button_content_fun ]
    , [> `Button ]
    , 'msg )
    many

(** [canvas ?key ?a children] produce a [<canvas>] element. *)
val canvas
  : ( [< Html_types.canvas_attrib ]
    , [< Html_types.canvas_content_fun ]
    , [> `Canvas ]
    , 'msg )
    many

(** [caption ?key ?a children] produce a [<caption>] element. *)
val caption
  : ( [< Html_types.caption_attrib ]
    , [< Html_types.caption_content_fun ]
    , [> `Caption ]
    , 'msg )
    many

(** [cite ?key ?a children] produce a [<cite>] element. *)
val cite
  : ( [< Html_types.cite_attrib ]
    , [< Html_types.cite_content_fun ]
    , [> `Cite ]
    , 'msg )
    many

(** [code ?key ?a children] produce a [<code>] element. *)
val code
  : ( [< Html_types.code_attrib ]
    , [< Html_types.code_content_fun ]
    , [> `Code ]
    , 'msg )
    many

(** [col ?key ?a ()] produce a [<col>] element. *)
val col : ([< Html_types.col_attrib ], [> `Col ], 'msg) leaf

(** [colgroup ?key ?a children] produce a [<colgroup>] element. *)
val colgroup
  : ( [< Html_types.colgroup_attrib ]
    , [< Html_types.colgroup_content_fun ]
    , [> `Colgroup ]
    , 'msg )
    many

(** [datalist ?key ?a children] produce a [<datalist>] element. *)
val datalist
  : ( [< Html_types.datalist_attrib ]
    , [< Html_types.selectoption ]
    , [> `Datalist ]
    , 'msg )
    many

(** [dd ?key ?a children] produce a [<dd>] element. *)
val dd
  : ( [< Html_types.dd_attrib ]
    , [< Html_types.dd_content_fun ]
    , [> `Dd ]
    , 'msg )
    many

(** [del ?key ?a children] produce a [<del>] element. *)
val del
  : ( [< Html_types.del_attrib ]
    , [< Html_types.del_content_fun ]
    , [> `Del ]
    , 'msg )
    many

(** [ins ?key ?a children] produce a [<ins>] element. *)
val ins
  : ( [< Html_types.ins_attrib ]
    , [< Html_types.ins_content_fun ]
    , [> `Ins ]
    , 'msg )
    many

(** [details ?key ?a children] produce a [<details>] element. *)
val details
  : ( [< Html_types.details_attrib ]
    , [< Html_types.details_content_fun ]
    , [> `Details ]
    , 'msg )
    many

(** [dfn ?key ?a children] produce a [<dfn>] element. *)
val dfn
  : ( [< Html_types.dfn_attrib ]
    , [< Html_types.dfn_content_fun ]
    , [> `Dfn ]
    , 'msg )
    many

(** [dialog ?key ?a children] produce a [<dialog>] element. *)
val dialog
  : ( [< Html_types.details_attrib ]
    , [< Html_types.details_content_fun ]
    (* FIXME: Need for a new release of TyXML (including <dialog>).  *)
    , [> `Details ]
    , 'msg )
    many

(** [dl ?key ?a children] produce a [<dl>] element. *)
val dl
  : ( [< Html_types.dl_attrib ]
    , [< Html_types.dl_content_fun ]
    , [> `Dl ]
    , 'msg )
    many

(** [dt ?key ?a children] produce a [<dt>] element. *)
val dt
  : ( [< Html_types.dt_attrib ]
    , [< Html_types.dt_content_fun ]
    , [> `Dt ]
    , 'msg )
    many

(** [em ?key ?a children] produce a [<em>] element. *)
val em
  : ( [< Html_types.em_attrib ]
    , [< Html_types.em_content_fun ]
    , [> `Em ]
    , 'msg )
    many

(** [embed ?key ?a ()] produce a [<embed>] element. *)
val embed : ([< Html_types.embed_attrib ], [> `Embed ], 'msg) leaf

(** [figcaption ?key ?a children] produce a [<figcaption>] element. *)
val figcaption
  : ( [< Html_types.figcaption_attrib ]
    , [< Html_types.figcaption_content_fun ]
    , [> `Figcaption ]
    , 'msg )
    many

(** [fieldset ?key ?a children] produce a [<fieldset>] element. *)
val fieldset
  :  ?legend:([< Html_types.legend ], 'msg) t
  -> ( [< Html_types.fieldset_attrib ]
     , [< Html_types.fieldset_content_fun ]
     , [> `Fieldset ]
     , 'msg )
     many

(** [figure ?figcaption ?key ?a children] produce a [<figure>] element. *)
val figure
  :  ?figcaption:
       [ `Top of ([< Html_types.figcaption ], 'msg) t
       | `Bottom of ([< Html_types.figcaption ], 'msg) t
       ]
  -> ( [< Html_types.figcaption_attrib ]
     , [< Html_types.figcaption_content_fun ]
     , [> `Figure ]
     , 'msg )
     many

(** [footer ?key ?a children] produce a [<footer>] element. *)
val footer
  : ( [< Html_types.footer_attrib ]
    , [< Html_types.footer_content_fun ]
    , [> `Footer ]
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

(** [form ?key ?a children] produce a [<form>] element. *)
val form
  : ( [< Html_types.form_attrib ]
    , [< Html_types.form_content_fun ]
    , [> `Form ]
    , 'msg )
    many

(** [h1 ?key ?a children] produce a [<h1>] element. *)
val h1
  : ( [< Html_types.h1_attrib ]
    , [< Html_types.h1_content_fun ]
    , [> `H1 ]
    , 'msg )
    many

(** [h2 ?key ?a children] produce a [<h2>] element. *)
val h2
  : ( [< Html_types.h2_attrib ]
    , [< Html_types.h2_content_fun ]
    , [> `H2 ]
    , 'msg )
    many

(** [h3 ?key ?a children] produce a [<h3>] element. *)
val h3
  : ( [< Html_types.h3_attrib ]
    , [< Html_types.h3_content_fun ]
    , [> `H3 ]
    , 'msg )
    many

(** [h4 ?key ?a children] produce a [<h4>] element. *)
val h4
  : ( [< Html_types.h4_attrib ]
    , [< Html_types.h4_content_fun ]
    , [> `H4 ]
    , 'msg )
    many

(** [h5 ?key ?a children] produce a [<h5>] element. *)
val h5
  : ( [< Html_types.h5_attrib ]
    , [< Html_types.h5_content_fun ]
    , [> `H5 ]
    , 'msg )
    many

(** [h6 ?key ?a children] produce a [<h6>] element. *)
val h6
  : ( [< Html_types.h6_attrib ]
    , [< Html_types.h6_content_fun ]
    , [> `H6 ]
    , 'msg )
    many

(** [header ?key ?a children] produce a [<header>] element. *)
val header
  : ( [< Html_types.header_attrib ]
    , [< Html_types.header_content_fun ]
    , [> `Header ]
    , 'msg )
    many

(** [hgroup ?key ?a children] produce a [<hgroup>] element. *)
val hgroup
  : ( [< Html_types.hgroup_attrib ]
    , [< Html_types.hgroup_content_fun ]
    , [> `Hgroup ]
    , 'msg )
    many

(** [i ?key ?a children] produce a [<i>] element. *)
val i
  : ( [< Html_types.i_attrib ]
    , [< Html_types.i_content_fun ]
    , [> `I ]
    , 'msg )
    many

(** [iframe ?key ?a children] produce a [<iframe>] element. *)
val iframe
  : ( [< Html_types.iframe_attrib ]
    , [< Html_types.iframe_content_fun ]
    , [> `Iframe ]
    , 'msg )
    many

(** [img ~src ~alt ?key ?a ()] produce a [<img>] element. *)
val img
  :  src:string
  -> alt:string
  -> ([< Html_types.img_attrib ], [> `Img ], 'msg) leaf

(** [input ?key ?a ()] produce a [<input>] element. *)
val input : ([< Html_types.input_attrib ], [> `Input ], 'msg) leaf

(** [kbd ?key ?a children] produce a [<kbd>] element. *)
val kbd
  : ( [< Html_types.kbd_attrib ]
    , [< Html_types.kbd_content_fun ]
    , [> `Kbd ]
    , 'msg )
    many

(** [label ?key ?a children] produce a [<label>] element. *)
val label
  : ( [< Html_types.label_attrib ]
    , [< Html_types.label_content_fun ]
    , [> `Label ]
    , 'msg )
    many

(** [legend ?key ?a children] produce a [<legend>] element. *)
val legend
  : ( [< Html_types.legend_attrib ]
    , [< Html_types.legend_content_fun ]
    , [> `Legend ]
    , 'msg )
    many

(** [li ?key ?a children] produce a [<li>] element. *)
val li
  : ( [< Html_types.li_attrib ]
    , [< Html_types.li_content_fun ]
    , [> `Li ]
    , 'msg )
    many

(** [link ~rel ~href ?key ?a ()] produce a [<input>] element. *)
val link
  :  rel:Html_types.linktypes
  -> href:string
  -> ([< Nightmare_tyxml.Attrib.Without_source.link ], [> `Link ], 'msg) leaf

(** [main ?key ?a children] produce a [<main>] element. *)
val main
  : ( [< Html_types.main_attrib ]
    , [< Html_types.main_content_fun ]
    , [> `Main ]
    , 'msg )
    many

(** [map ?key ?a children] produce a [<map>] element. *)
val map
  : ([< Html_types.map_attrib ], 'children, 'children Html_types.map, 'msg) many

(** [mark ?key ?a children] produce a [<mark>] element. *)
val mark
  : ( [< Html_types.mark_attrib ]
    , [< Html_types.mark_content_fun ]
    , [> `Mark ]
    , 'msg )
    many

(** [menu ?key ?a children] produce a [<menu>] element. *)
val menu
  : ( [< Html_types.menu_attrib ]
    , [< Html_types.li | Html_types.script | Html_types.template ]
    , [> `Menu ]
    , 'msg )
    many

(** [meter ?key ?a children] produce a [<meter>] element. *)
val meter
  : ( [< Html_types.meter_attrib ]
    , [< Html_types.meter_content_fun ]
    , [> `Meter ]
    , 'msg )
    many

(** [nav ?key ?a children] produce a [<nav>] element. *)
val nav
  : ( [< Html_types.nav_attrib ]
    , [< Html_types.nav_content_fun ]
    , [> `Nav ]
    , 'msg )
    many

(** [object_ ?key ?a children] produce a [<object>] element. *)
val object_
  : ( [< Html_types.object__attrib ]
    , Html_types.object__content
    , [> Html_types.object__ ]
    , 'msg )
    many

(** [ol ?key ?a children] produce a [<ol>] element. *)
val ol
  : ([< Html_types.ol_attrib ], Html_types.ol_content_fun, [> `Ol ], 'msg) many

(** [ul ?key ?a children] produce a [<ul>] element. *)
val ul
  : ([< Html_types.ul_attrib ], Html_types.ul_content_fun, [> `Ul ], 'msg) many

(** [optgroup ?key ?a children] produce a [<optgroup>] element. *)
val optgroup
  :  label:string
  -> ( [< Html_types.optgroup_attrib > `Label ]
     , Html_types.optgroup_content_fun
     , [> `Optgroup ]
     , 'msg )
     many

(** [option ?key ?a value] produce a [<option>] element. *)
val option : ([< Html_types.option_attrib ], string, [> `Option ], 'msg) one

(** [output ?key ?a children] produce a [<output>] element. *)
val output
  : ( [< Html_types.output_elt_attrib ]
    , Html_types.output_elt_content_fun
    , [> `Output ]
    , 'msg )
    many

(** [p ?key ?a children] produce a [<p>] element. *)
val p : ([< Html_types.p_attrib ], Html_types.p_content_fun, [> `P ], 'msg) many

(** [picture ~img ?key ?a children] produce a [<picture>] element. *)
val picture
  :  img:([< Html_types.img ], 'msg) t
  -> ( [< Html_types.picture_attrib ]
     , Html_types.picture_content_fun
     , [> `Picture ]
     , 'msg )
     many

(** [pre ?key ?a children] produce a [<pre>] element. *)
val pre
  : ( [< Html_types.pre_attrib ]
    , Html_types.pre_content_fun
    , [> `Pre ]
    , 'msg )
    many

(** [progress ?key ?a children] produce a [<progress>] element. *)
val progress
  : ( [< Html_types.progress_attrib ]
    , Html_types.progress_content_fun
    , [> `Progress ]
    , 'msg )
    many

(** [q ?key ?a children] produce a [<q>] element. *)
val q : ([< Html_types.q_attrib ], Html_types.q_content_fun, [> `Q ], 'msg) many

(** [rp ?key ?a children] produce a [<rp>] element. *)
val rp
  : ([< Html_types.rp_attrib ], Html_types.rp_content_fun, [> `Rp ], 'msg) many

(** [rt ?key ?a children] produce a [<rt>] element. *)
val rt
  : ([< Html_types.rt_attrib ], Html_types.rt_content_fun, [> `Rt ], 'msg) many

(** [ruby ?key ?a children] produce a [<ruby>] element. *)
val ruby
  : ( [< Html_types.ruby_attrib ]
    , Html_types.ruby_content_fun
    , [> `Ruby ]
    , 'msg )
    many

(** [samp ?key ?a children] produce a [<samp>] element. *)
val samp
  : ( [< Html_types.samp_attrib ]
    , Html_types.samp_content_fun
    , [> `Samp ]
    , 'msg )
    many

(** [script ?key ?a value] produce a [<script>] element. *)
val script : ([< Html_types.script_attrib ], string, [> `Script ], 'msg) one

(** [section ?key ?a children] produce a [<section>] element. *)
val section
  : ( [< Html_types.section_attrib ]
    , Html_types.section_content_fun
    , [> `Section ]
    , 'msg )
    many

(** [select ?key ?a children] produce a [<select>] element. *)
val select
  : ( [< Html_types.select_attrib ]
    , Html_types.select_content_fun
    , [> `Select ]
    , 'msg )
    many

(** [small ?key ?a children] produce a [<small>] element. *)
val small
  : ( [< Html_types.small_attrib ]
    , Html_types.small_content_fun
    , [> `Small ]
    , 'msg )
    many

(** [source ?key ?a ()] produce a [<source>] element. *)
val source : ([< Html_types.source_attrib ], [> `Source ], 'msg) leaf

(** [span ?key ?a children] produce a [<span>] element. *)
val span
  : ( [< Html_types.span_attrib ]
    , Html_types.span_content_fun
    , [> `Span ]
    , 'msg )
    many

(** [strong ?key ?a children] produce a [<strong>] element. *)
val strong
  : ( [< Html_types.strong_attrib ]
    , Html_types.strong_content_fun
    , [> `Strong ]
    , 'msg )
    many

(** [style ?key ?a children] produce a [<style>] element. *)
val style
  : ( [< Html_types.style_attrib ]
    , Html_types.style_content_fun
    , [> `Style ]
    , 'msg )
    many

(** [sub ?key ?a children] produce a [<sub>] element. *)
val sub
  : ( [< Html_types.sub_attrib ]
    , Html_types.sub_content_fun
    , [> `Sub ]
    , 'msg )
    many

(** [sup ?key ?a children] produce a [<sup>] element. *)
val sup
  : ( [< Html_types.sup_attrib ]
    , Html_types.sup_content_fun
    , [> `Sup ]
    , 'msg )
    many

(** [summary ?key ?a children] produce a [<summary>] element. *)
val summary
  : ( [< Html_types.summary_attrib ]
    , Html_types.summary_content_fun
    , [> `Summary ]
    , 'msg )
    many

(** {1 Node helpers} *)

val remove_node_kind : ('a, 'msg) t -> 'msg Vdom.vdom
