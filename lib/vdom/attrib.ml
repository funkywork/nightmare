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

type (+_, +'msg) t = 'msg Vdom.attribute
type _ custom_event = Vdom.Custom.event

let attr key value = Vdom.Attribute (key, value)
let string attr value = Vdom.Property (attr, String value)
let bool attr value = Vdom.Property (attr, Bool value)
let int attr value = Vdom.Property (attr, Int value)
let to_string f attr value = string attr (f value)
let concat_with_space x y = x ^ " " ^ y
let concat_with_comma x y = x ^ "," ^ y
let string_option = to_string (Option.value ~default:"")

let charlist =
  to_string
    (List.fold_left
       (fun acc char -> concat_with_space acc @@ String.make 1 char)
       "")
;;

let tokenize x = String.trim (String.lowercase_ascii x)
let list_with f = List.fold_left (fun acc x -> concat_with_space acc (f x)) ""
let list_comma f = List.fold_left (fun acc x -> concat_with_comma acc (f x)) ""
let string_list = list_with (fun x -> x)
let string_list_comma = list_comma (fun x -> x)
let int_list = list_comma string_of_int
let tokenize_list_with f = list_with (fun x -> x |> f |> tokenize)
let tokenize_list = tokenize_list_with (fun x -> x)
let strings = to_string string_list
let tokens = to_string tokenize_list
let tokens_with f = to_string (tokenize_list_with f)
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

(* Specifics attributes *)

let a_href value = string "href" value
let a_hreflang value = string "hreflang" value
let a_download ?new_name () = string_option "download" new_name
let a_ping value = strings "ping" value

let a_rel value =
  tokens_with
    (function
     | `Alternate -> "alternate"
     | `Archives -> "archives"
     | `Author -> "author"
     | `Bookmark -> "bookmark"
     | `Canonical -> "canonical"
     | `External -> "external"
     | `First -> "first"
     | `Help -> "help"
     | `Icon -> "icon"
     | `Index -> "index"
     | `Last -> "last"
     | `License -> "license"
     | `Next -> "next"
     | `Nofollow -> "nofollow"
     | `Noreferrer -> "noreferrer"
     | `Noopener -> "noopener"
     | `Pingback -> "pingback"
     | `Prefetch -> "prefetch"
     | `Prev -> "prev"
     | `Search -> "search"
     | `Stylesheet -> "stylesheet"
     | `Sidebar -> "sidebar"
     | `Tag -> "tag"
     | `Up -> "up"
     | `Other s -> s)
    "rel"
    value
;;

let a_mime_type value = string "type" value

let a_target value =
  to_string
    (function
     | `Self -> "_self"
     | `Blank -> "_blank"
     | `Parent -> "_parent"
     | `Top -> "_top"
     | `Other x -> x)
    "target"
    value
;;

let a_coords value = to_string int_list "coords" value

let a_shape value =
  to_string
    (function
     | `Rect -> "rect"
     | `Circle -> "circle"
     | `Poly -> "poly"
     | `Default -> "default")
    "shape"
    value
;;

let a_src value = string "src" value
let a_autoplay value = bool "autoplay" value
let a_controls value = bool "controls" value

let a_crossorigin value =
  to_string
    (function
     | `Anonymous -> "anonymous"
     | `Use_credentials -> "user-credentials")
    "crossorigin"
    value
;;

let a_loop value = bool "loop" value
let a_muted value = bool "muted" value

let a_preload value =
  to_string
    (function
     | `None -> "none"
     | `Metadata -> "metadata"
     | `Auto -> "auto")
    "preload"
    value
;;

let a_height value = int "height" value
let a_width value = int "width" value
let a_poster value = string "poster" value
let a_cite value = string "cite" value
let a_autofocus value = bool "autofocus" value
let a_disabled value = bool "disabled" value
let a_form value = string "form" value
let a_formaction value = string "formAction" value
let a_formenctype value = string "formEnctype" value
let a_formnovalidate value = bool "formNoValidate" value

let a_formtarget value =
  to_string
    (function
     | `Self -> "_self"
     | `Blank -> "_blank"
     | `Parent -> "_parent"
     | `Top -> "_top"
     | `Other x -> x)
    "formTarget"
    value
;;

let a_name value = to_string tokenize "name" value

let a_button_type value =
  to_string
    (function
     | `Button -> "button"
     | `Submit -> "submit"
     | `Reset -> "reset")
    "type"
    value
;;

let a_value value = string "value" value
let a_span value = int "span" value
let a_datetime value = string "dateTime" value
let a_open value = bool "open" value
let a_accept_charset value = tokens "acceptCharset" value

let a_autocomplete value =
  to_string
    (function
     | true -> "on"
     | false -> "off")
    "autocomplete"
    value
;;

let a_action value = string "action" value
let a_enctype value = string "enctype" value

let a_formmethod value =
  to_string
    (function
     | `GET -> "get"
     | `POST -> "post")
    "formMethod"
    value
;;

let a_method value =
  to_string
    (function
     | `GET -> "get"
     | `POST -> "post")
    "method"
    value
;;

let a_novalidate value = bool "noValidate" value

let a_referrerpolicy value =
  to_string
    (function
     | `Empty -> ""
     | `No_referrer -> "no-referrer"
     | `No_referrer_when_downgrade -> "no-referrer-when-downgrade"
     | `Origin -> "origin"
     | `Origin_when_cross_origin -> "origin-when-cross-origin"
     | `Same_origin -> "same-origin"
     | `Strict_origin -> "strict-origin"
     | `Strict_origin_when_cross_origin -> "strict-origin-when-cross-origin"
     | `Unsafe_url -> "unsafe-url")
    "referrerPolicy"
    value
;;

let a_sandbox value =
  to_string
    (tokenize_list_with (function
      | `Allow_forms -> "allow-forms"
      | `Allow_pointer_lock -> "allow-pointer-lock"
      | `Allow_popups -> "allow-popups"
      | `Allow_top_navigation -> "allow-top-navigation"
      | `Allow_same_origin -> "allow-same-origin"
      | `Allow_script -> "allow-scripts"))
    "sandbox"
    value
;;

let a_ismap value = bool "isMap" value
let a_alt value = string "alt" value
let a_accept value = to_string string_list_comma "accept" value
let a_checked value = bool "checked" value
let a_list value = to_string tokenize "list" value

let a_input_max value =
  to_string
    (function
     | `Number x -> string_of_int x
     | `Datetime x -> x)
    "max"
    value
;;

let a_input_min value =
  to_string
    (function
     | `Number x -> string_of_int x
     | `Datetime x -> x)
    "min"
    value
;;

let a_maxlength value = int "maxLength" value
let a_minlength value = int "minLength" value
let a_multiple value = bool "multiple" value
let a_pattern value = string "pattern" value
let a_placeholder value = string "placeholder" value
let a_readonly value = bool "readOnly" value
let a_required value = bool "required" value
let a_size value = int "size" value
let a_step value = to_string string_of_float "step" value

let a_input_type value =
  to_string
    (function
     | `Url -> "url"
     | `Tel -> "tel"
     | `Text -> "text"
     | `Time -> "time"
     | `Search -> "search"
     | `Password -> "password"
     | `Checkbox -> "checkbox"
     | `Range -> "range"
     | `Radio -> "radio"
     | `Submit -> "submit"
     | `Reset -> "reset"
     | `Number -> "number"
     | `Hidden -> "hidden"
     | `Month -> "month"
     | `Week -> "week"
     | `File -> "file"
     | `Email -> "email"
     | `Image -> "image"
     | `Datetime_local -> "datetime-local"
     | `Datetime -> "datetime"
     | `Date -> "date"
     | `Color -> "color"
     | `Button -> "button")
    "type"
    value
;;

(* Util *)

let remove_attribute_kind x = x
let remove_attribute_kinds x = x
