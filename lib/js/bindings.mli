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
class type console_hook = object
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

class type ['a] readable_stream_result = object
  method _done : bool t readonly_prop
  method value : 'a readonly_prop
end

class type ['a] readable_stream_default_reader = object
  method closed : bool t readonly_prop
  method cancel : js_string t or_undefined -> unit Promise.t meth
  method close : unit Promise.t meth
  method read : 'a readable_stream_result t Promise.t meth
  method releaseLock : unit meth
end

class type ['a] readable_stream = object
  method locked : bool t readonly_prop
  method cancel : js_string t or_undefined -> unit Promise.t meth
  method getReader : 'a readable_stream_default_reader t meth
end

class type blob = object
  method size : int readonly_prop
  method _type : js_string t readonly_prop
  method arrayBuffer : Typed_array.arrayBuffer t Promise.t meth
  method slice : int -> int -> js_string t or_undefined -> blob t meth
  method stream : Typed_array.uint8Array t readable_stream t meth
  method text : js_string t Promise.t meth
end

class type http_headers = object
  method append : js_string t -> js_string t -> unit meth
  method delete : js_string t -> unit meth
  method get : js_string t -> js_string t opt meth
  method has : js_string t -> bool t meth
  method set : js_string t -> js_string t -> unit meth
end

class type form_data = object
  inherit http_headers
  method getAll : js_string t -> js_string t js_array t meth
end

class type url_search_params = object
  inherit form_data
  method toString : js_string t meth
  method sort : unit meth
end

type fetch_body

class type fetch_options = object
  method _method : js_string t readonly_prop
  method headers : http_headers t or_undefined readonly_prop
  method body : fetch_body t or_undefined readonly_prop
  method mode : js_string t or_undefined readonly_prop
  method credentials : js_string t or_undefined readonly_prop
  method cache : js_string t or_undefined readonly_prop
  method redirect : js_string t or_undefined readonly_prop
  method referrer : js_string t or_undefined readonly_prop
  method referrerPolicy : js_string t or_undefined readonly_prop
  method integrity : js_string t or_undefined readonly_prop
  method keepalive : bool t or_undefined readonly_prop
end

class type fetch_response = object
  method headers : http_headers t readonly_prop
  method ok : bool t readonly_prop
  method redirected : bool t readonly_prop
  method status : int readonly_prop
  method statusText : js_string t readonly_prop
  method _type : js_string t readonly_prop
  method url : js_string t readonly_prop
  method body : Typed_array.uint8Array t readable_stream t readonly_prop
  method text : js_string t Promise.t meth
  method arrayBuffer : Typed_array.arrayBuffer t Promise.t meth
  method blob : blob t Promise.t meth
  method formData : form_data t Promise.t meth
end
