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

(** The global fetch() method starts the process of fetching a resource from the
    network, returning a promise which is fulfilled once the response is
    available. *)

open Js_of_ocaml

(** {1 Types} *)

type body =
  [ `Blob of Blob.t
  | `FormData of Form_data.t
  | `UrlSearchParams of Url_search_params.t
  | `String of string
  | `ReadableStream of Typed_array.uint8Array Js.t Stream.Readable.t
  ]

type mode =
  [ `Cors
  | `No_cors
  | `Same_origin
  ]

type credentials =
  [ `Omit
  | `Same_origin
  | `Include
  ]

type cache =
  [ `Default
  | `No_store
  | `Reload
  | `No_cache
  | `Force_cache
  | `Only_if_cached
  ]

type redirect =
  [ `Follow
  | `Error
  | `Manual
  ]

type referrer =
  [ `No_referrer
  | `Client
  | `Refer_to of string
  ]

type referrer_policy =
  [ `No_referrer
  | `No_referrer_when_downgrade
  | `Origin
  | `Origin_when_cross_origin
  | `Unsafe_url
  ]

type response_type =
  [ `Basic
  | `Cors
  | `Error
  | `Opaque
  | `Opaque_redirect
  ]

(** {1 Response} *)

module Response : sig
  (** The Response interface of the Fetch API represents the response to a
      request. *)

  type t = Bindings.fetch_response Js.t

  val headers : t -> Headers.t
  val is_ok : t -> bool
  val is_redirected : t -> bool
  val status : t -> int
  val type_ : t -> response_type
  val url : t -> string
  val body : t -> Typed_array.uint8Array Js.t Stream.Readable.t
  val text : t -> string Lwt.t
  val array_buffer : t -> Typed_array.arrayBuffer Js.t Lwt.t
  val blob : t -> Blob.t Lwt.t
  val form_data : t -> Form_data.t Lwt.t
end

(** {1 API} *)

(** A [fetch] promise only rejects when a network error is encountered (which is
    usually when there's a permissions issue or similar). A fetch() promise does
    not reject on HTTP errors (404, etc.). Instead, a then() handler must check
    the Response.ok and/or Response.status properties. *)

(** [fetch ~method_ target] perform a [fetch] request. *)
val fetch
  :  ?headers:Headers.t
  -> ?body:body
  -> ?mode:mode
  -> ?credentials:credentials
  -> ?cache:cache
  -> ?redirect:redirect
  -> ?referrer:referrer
  -> ?referrer_policy:referrer_policy
  -> ?integrity:string
  -> ?keepalive:bool
  -> method_:[< Nightmare_service.Method.t ]
  -> string
  -> Response.t Lwt.t

(** {2 Specialized fetch} *)

val get
  :  ?headers:Headers.t
  -> ?mode:mode
  -> ?credentials:credentials
  -> ?cache:cache
  -> ?redirect:redirect
  -> ?referrer:referrer
  -> ?referrer_policy:referrer_policy
  -> ?integrity:string
  -> ?keepalive:bool
  -> string
  -> Response.t Lwt.t

val head
  :  ?headers:Headers.t
  -> ?mode:mode
  -> ?credentials:credentials
  -> ?cache:cache
  -> ?redirect:redirect
  -> ?referrer:referrer
  -> ?referrer_policy:referrer_policy
  -> ?integrity:string
  -> ?keepalive:bool
  -> string
  -> Response.t Lwt.t

val post
  :  ?headers:Headers.t
  -> ?body:body
  -> ?mode:mode
  -> ?credentials:credentials
  -> ?cache:cache
  -> ?redirect:redirect
  -> ?referrer:referrer
  -> ?referrer_policy:referrer_policy
  -> ?integrity:string
  -> ?keepalive:bool
  -> string
  -> Response.t Lwt.t

val put
  :  ?headers:Headers.t
  -> ?body:body
  -> ?mode:mode
  -> ?credentials:credentials
  -> ?cache:cache
  -> ?redirect:redirect
  -> ?referrer:referrer
  -> ?referrer_policy:referrer_policy
  -> ?integrity:string
  -> ?keepalive:bool
  -> string
  -> Response.t Lwt.t

val delete
  :  ?headers:Headers.t
  -> ?body:body
  -> ?mode:mode
  -> ?credentials:credentials
  -> ?cache:cache
  -> ?redirect:redirect
  -> ?referrer:referrer
  -> ?referrer_policy:referrer_policy
  -> ?integrity:string
  -> ?keepalive:bool
  -> string
  -> Response.t Lwt.t

val connect
  :  ?headers:Headers.t
  -> ?body:body
  -> ?mode:mode
  -> ?credentials:credentials
  -> ?cache:cache
  -> ?redirect:redirect
  -> ?referrer:referrer
  -> ?referrer_policy:referrer_policy
  -> ?integrity:string
  -> ?keepalive:bool
  -> string
  -> Response.t Lwt.t

val options
  :  ?headers:Headers.t
  -> ?body:body
  -> ?mode:mode
  -> ?credentials:credentials
  -> ?cache:cache
  -> ?redirect:redirect
  -> ?referrer:referrer
  -> ?referrer_policy:referrer_policy
  -> ?integrity:string
  -> ?keepalive:bool
  -> string
  -> Response.t Lwt.t

val trace
  :  ?headers:Headers.t
  -> ?body:body
  -> ?mode:mode
  -> ?credentials:credentials
  -> ?cache:cache
  -> ?redirect:redirect
  -> ?referrer:referrer
  -> ?referrer_policy:referrer_policy
  -> ?integrity:string
  -> ?keepalive:bool
  -> string
  -> Response.t Lwt.t

val patch
  :  ?headers:Headers.t
  -> ?body:body
  -> ?mode:mode
  -> ?credentials:credentials
  -> ?cache:cache
  -> ?redirect:redirect
  -> ?referrer:referrer
  -> ?referrer_policy:referrer_policy
  -> ?integrity:string
  -> ?keepalive:bool
  -> string
  -> Response.t Lwt.t

(** {2 Fetch from endpoint} *)

val from
  :  ?parameters:(string * string) list
  -> ?headers:Headers.t
  -> ?body:body
  -> ?mode:mode
  -> ?credentials:credentials
  -> ?cache:cache
  -> ?redirect:redirect
  -> ?referrer:referrer
  -> ?referrer_policy:referrer_policy
  -> ?integrity:string
  -> ?keepalive:bool
  -> ( _
     , Nightmare_service.Method.t
     , 'continuation
     , Response.t Lwt.t )
     Nightmare_service.Endpoint.wrapped
  -> 'continuation
