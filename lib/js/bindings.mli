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

(** Low-level bindings with the JavaScript API. Ideally, these bindings should
    be hidden behind a higher-level API. *)

open Js_of_ocaml
open Js
open Aliases

(** {1 Console Bindings}

    Binding to deal with the browser console. *)

(** Javascript object. *)
class type console_hook =
  object
    inherit Firebug.console
    method clear : unit meth
    method count : js_string t or_undefined -> unit meth
    method countReset : js_string t or_undefined -> unit meth
    method timeLog : 'a. js_string t -> 'a -> unit meth
    method table : 'a. 'a -> js_string t js_array t or_undefined -> unit meth
  end

(** {1 Fetch API}

    A rough attempt to make a binding for fetch.
    {{:https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API} MDN
      documentation} *)

class type http_headers =
  object
    method append : js_string t -> js_string t -> unit meth
    method delete : js_string t -> unit meth
    method get : js_string t -> js_string t opt meth
    method has : js_string t -> bool t meth
    method set : js_string t -> js_string t -> unit meth
  end

class type fetch_options =
  object
    method _method : js_string t readonly_prop
    method headers : http_headers t or_undefined readonly_prop
  end
