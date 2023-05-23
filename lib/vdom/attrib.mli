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

(** Describes HTML attributes *)

(** An attribute has the type [('kind, 'message) t], the ['kind] is a phantom
    type to allows only valid attributes in nodes. *)
type (+_, +'msg) t

(** An indexed custom event. *)
type +_ custom_event = Vdom.Custom.event

(** {1 Universal attributes}

    Global attributes are attributes common to all HTML elements; they can be
    used on all elements, though they may have no effect on some elements. *)

val a_accesskey : char list -> ([> `Accesskey ], 'msg) t

val a_autocapitalize
  :  [< `None | `Sentences | `Words | `Characters ]
  -> ([> `Autocapitalize ], 'msg) t

val a_class : string list -> ([> `Class ], 'msg) t
val a_contenteditable : bool -> ([> `Contenteditable ], 'msg) t
val a_dir : [< `Rtl | `Ltr | `Auto ] -> ([> `Dir ], 'msg) t
val a_draggable : bool -> ([> `Draggable ], 'msg) t

val a_enterkeyhint
  :  [< `Enter | `Done | `Go | `Next | `Previous | `Search | `Send ]
  -> ([> `Enterkeyhint ], 'msg) t

val a_hidden : [< `Hidden | `Until_found ] -> ([> `Hidden ], 'msg) t
val a_id : string -> ([> `Id ], 'msg) t
val a_inert : bool -> ([> `Inert ], 'msg) t

val a_inputmode
  :  [< `None | `Text | `Decimal | `Numeric | `Tel | `Search | `Email | `Url ]
  -> ([> `Inputmode ], 'msg) t

val a_is : string -> ([> `Is ], 'msg) t
val a_lang : string -> ([> `Lang ], 'msg) t
val a_nonce : string -> ([> `Nonce ], 'msg) t
val a_part : string list -> ([> `Part ], 'msg) t
val a_role : string list -> ([> `Role ], 'msg) t
val a_aria : string -> string list -> ([> `Arial ], 'msg) t
val a_slot : string -> ([> `Slot ], 'msg) t
val a_spellcheck : bool -> ([> `Spellcheck ], 'msg) t
val a_style : string -> string -> ([> `Style_Attr ], 'msg) t
val a_tabindex : int -> ([> `Tabindex ], 'msg) t
val a_title : string -> ([> `Title ], 'msg) t
val a_translate : bool -> ([> `Translate ], 'msg) t

(** {1 Data attributes}

    Forms a class of attributes, called custom data attributes, that allow
    proprietary information to be exchanged between the HTML and its DOM
    representation that may be used by scripts.

    All custom (or data attributes) are prefixed by [data-]. *)

val a_custom : key:string -> string -> ([> `User_data ], 'msg) t

(** {1 Microdata attributes}

    Microdata is part of the WHATWG HTML Standard and is used to nest metadata
    within existing content on web pages. Search engines and web crawlers can
    extract and process microdata from a web page and use it to provide a richer
    browsing experience for users. *)

val a_itemid : string -> ([> `Itemid ], 'msg) t
val a_itemref : string list -> ([> `Itemref ], 'msg) t
val a_itemprop : string -> ([> `Itemprop ], 'msg) t
val a_itemtype : string -> ([> `Itemtype ], 'msg) t
val a_itemscope : unit -> ([> `Itemscope ], 'msg) t

(** {1 Event Handlers} *)

val on_focus : 'msg -> ([> `OnFocus ], 'msg) t
val on_blur : 'msg -> ([> `OnBlur ], 'msg) t
val on_input : (string -> 'msg) -> ([> `OnInput ], 'msg) t
val on_change : (string -> 'msg) -> ([> `OnChange ], 'msg) t
val on_change_checked : (bool -> 'msg) -> ([> `OnChange ], 'msg) t
val on_change_index : (int -> 'msg) -> ([> `OnChange ], 'msg) t
val on_mousedown : (Vdom.mouse_event -> 'msg) -> ([> `OnMouseDown ], 'msg) t
val on_click : (Vdom.mouse_event -> 'msg) -> ([> `OnClick ], 'msg) t
val on_doubleclick : (Vdom.mouse_event -> 'msg) -> ([> `OnDblClick ], 'msg) t
val on_contextmenu : (Vdom.mouse_event -> 'msg) -> ([> `OnContextMenu ], 'msg) t
val on_mousemove : (Vdom.mouse_event -> 'msg) -> ([> `OnMouseMove ], 'msg) t
val on_keydown : (Vdom.key_event -> 'msg) -> ([> `OnKeyDown ], 'msg) t
val on_custom : ('kind custom_event -> 'msg option) -> ('kind, 'msg) t

(** {1 Specifics attributes} *)

val a_href : string -> ([> `Href ], 'msg) t
val a_hreflang : string -> ([> `Hreflang ], 'msg) t
val a_download : ?new_name:string -> unit -> ([> `Download ], 'msg) t
val a_ping : string list -> ([> `Ping ], 'msg) t
val a_rel : Html_types.linktypes -> ([> `Rel ], 'msg) t
val a_mime_type : string -> ([> `Mime_type ], 'msg) t
val a_coords : int list -> ([> `Coords ], 'msg) t
val a_shape : [< `Rect | `Circle | `Poly | `Default ] -> ([> `Shape ], 'msg) t

val a_target
  :  [< `Self | `Blank | `Parent | `Top | `Other of string ]
  -> ([> `Target ], 'msg) t

val a_src : string -> ([> `Src ], 'msg) t
val a_autoplay : unit -> ([> `Autoplay ], 'msg) t
val a_controls : unit -> ([> `Controls ], 'msg) t

val a_crossorigin
  :  [< `Anonymous | `Use_credentials ]
  -> ([> `Crossorigin ], 'msg) t

val a_loop : unit -> ([> `Loop ], 'msg) t
val a_muted : unit -> ([> `Muted ], 'msg) t
val a_preload : [< `None | `Metadata | `Auto ] -> ([> `Preload ], 'msg) t
val a_height : int -> ([> `Height ], 'msg) t
val a_poster : string -> ([> `Poster ], 'msg) t
val a_width : int -> ([> `Width ], 'msg) t
val a_cite : string -> ([> `Cite ], 'msg) t

(** {1 Attribut helpers} *)

val remove_attribute_kind : ('a, 'msg) t -> 'msg Vdom.attribute
val remove_attribute_kinds : ('a, 'msg) t list -> 'msg Vdom.attribute list
