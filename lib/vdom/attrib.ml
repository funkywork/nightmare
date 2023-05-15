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

type (_, 'msg) t = 'msg Vdom.attribute
type _ custom_event = Vdom.Custom.event

let attr key value = Vdom.Attribute (key, value)
let string attr value = Vdom.Property (attr, String value)
let bool attr value = Vdom.Property (attr, Bool value)
let int attr value = Vdom.Property (attr, Int value)
let to_string f attr value = string attr (f value)
let concat_with_space x y = x ^ " " ^ y

let charlist =
  to_string
    (List.fold_left
       (fun acc char -> concat_with_space acc @@ String.make 1 char)
       "")
;;

let tokenize x = String.trim (String.lowercase_ascii x)

let tokenize_list =
  List.fold_left (fun acc token -> concat_with_space acc @@ tokenize token) ""
;;

let tokens = to_string tokenize_list
let custom_property x = "data-" ^ tokenize x

(* Universal attributes *)

let a_accesskey = charlist "accesskey"

let a_autocapitalize value =
  to_string
    (function
     | `None -> "none"
     | `Sentences -> "sentences"
     | `Words -> "words"
     | `Characters -> "characters")
    "autocapitalize"
    value
;;

let a_class value = tokens "className" value
let a_contenteditable value = bool "contentEditable" value

let a_dir value =
  to_string
    (function
     | `Rtl -> "rtl"
     | `Ltr -> "ltr"
     | `Auto -> "auto")
    "dir"
    value
;;

let a_draggable value = bool "draggable" value

let a_enterkeyhint value =
  to_string
    (function
     | `Enter -> "enter"
     | `Done -> "done"
     | `Go -> "go"
     | `Next -> "next"
     | `Previous -> "previous"
     | `Search -> "search"
     | `Send -> "send")
    "enterkeyhint"
    value
;;

let a_hidden value =
  to_string
    (function
     | `Hidden -> "hidden"
     | `Until_found -> "until-found")
    "hidden"
    value
;;

let a_id value = string "id" value
let a_inert value = bool "inert" value

let a_inputmode value =
  to_string
    (function
     | `None -> "none"
     | `Text -> "text"
     | `Decimal -> "decimal"
     | `Numeric -> "numeric"
     | `Tel -> "tel"
     | `Search -> "search"
     | `Email -> "email"
     | `Url -> "url")
    "inputMode"
    value
;;

let a_lang value = string "lang" value
let a_nonce value = string "nonce" value
let a_is value = attr "is" value
let a_part value = tokens "part" value
let a_role value = attr "role" (tokenize_list value)
let a_aria key value = attr ("aria-" ^ tokenize key) (tokenize_list value)
let a_slot value = string "slot" value
let a_spellcheck value = bool "spellcheck" value
let a_style key value = Vdom.Style (key, value)
let a_tabindex value = int "tabIndex" value
let a_title value = string "title" value
let a_translate value = bool "translate" value

(* Custon attributes *)

let a_custom ~key value = string (custom_property key) value

(* Microdata element *)

let a_itemid value = attr "itemid" value
let a_itemref value = attr "itemref" @@ tokenize_list value
let a_itemprop value = attr "itemprop" value
let a_itemtype value = attr "itemtype" value
let a_itemscope () = attr "itemscope" "itemscope"

(* Event Handling *)

let on_mousedown f = Vdom.onmousedown f
let on_click f = Vdom.onclick f
let on_doubleclick f = Vdom.ondblclick f
let on_contextmenu f = Vdom.oncontextmenu f
let on_focus msg = Vdom.onfocus msg
let on_blur msg = Vdom.onblur msg
let on_input f = Vdom.oninput f
let on_change f = Vdom.onchange f
let on_change_checked f = Vdom.onchange_checked f
let on_change_index f = Vdom.onchange_index f
let on_mousemove f = Vdom.onmousemove f
let on_keydown f = Vdom.onkeydown f
let on_custom f = Vdom.oncustomevent f

(* Util *)

let remove_attribute_kind x = x
