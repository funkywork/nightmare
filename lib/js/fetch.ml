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

open Js_of_ocaml

type body =
  [ `Blob of Blob.t
  | `FormData of Form_data.t
  | `UrlSearchParams of Url_search_params.t
  | `String of string
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

let method_to_string = function
  | `GET -> "GET"
  | `POST -> "POST"
  | `PUT -> "PUT"
  | `DELETE -> "DELETE"
  | `PATCH -> "PATCH"
  | `HEAD -> "HEAD"
  | `CONNECT -> "CONNECT"
  | `OPTIONS -> "OPTIONS"
  | `TRACE -> "TRACE"
;;

let pack_body x : Bindings.fetch_body Js.t =
  match x with
  | `Blob b -> Js.Unsafe.coerce b
  | `FormData f -> Js.Unsafe.coerce f
  | `UrlSearchParams p -> Js.Unsafe.coerce p
  | `String x -> Js.Unsafe.coerce (Js.string x)
;;

let mode_to_string = function
  | `Cors -> "cors"
  | `No_cors -> "no-cors"
  | `Same_origin -> "same-origin"
;;

let credentials_to_string = function
  | `Omit -> "omit"
  | `Same_origin -> "same-origin"
  | `Include -> "include"
;;

let cache_to_string = function
  | `Default -> "default"
  | `No_store -> "no-store"
  | `Reload -> "reload"
  | `No_cache -> "no-cache"
  | `Force_cache -> "force-cache"
  | `Only_if_cached -> "only-if-cached"
;;

let redirect_to_string = function
  | `Follow -> "follow"
  | `Error -> "error"
  | `Manual -> "manual"
;;

let referrer_to_string = function
  | `No_referrer -> "no-referrer"
  | `Client -> "client"
  | `Refer_to x -> x
;;

let referrer_policy_to_string = function
  | `No_referrer -> "no-referrer"
  | `No_referrer_when_downgrade -> "no-referrer-when-downgrade"
  | `Origin -> "origin"
  | `Origin_when_cross_origin -> "origin-when-cross-origin"
  | `Unsafe_url -> "unsafe-url"
;;

module Response = struct
  type t = Bindings.fetch_response Js.t
end

let make_options
  method_
  headers
  body
  mode
  credentials
  cache
  redirect
  referrer
  referrer_policy
  integrity
  keepalive
  : Bindings.fetch_options Js.t
  =
  let open Optional.Option in
  let open Preface.Fun.Infix in
  object%js
    val _method = method_to_string method_ |> Js.string
    val headers = headers |> to_optdef
    val body = pack_body <$> body |> to_optdef
    val mode = Js.string % mode_to_string <$> mode |> to_optdef

    val credentials =
      Js.string % credentials_to_string <$> credentials |> to_optdef

    val cache = Js.string % cache_to_string <$> cache |> to_optdef
    val redirect = Js.string % redirect_to_string <$> redirect |> to_optdef
    val referrer = Js.string % referrer_to_string <$> referrer |> to_optdef

    val referrerPolicy =
      Js.string % referrer_policy_to_string <$> referrer_policy |> to_optdef

    val integrity = Js.string <$> integrity |> to_optdef
    val keepalive = Js.bool <$> keepalive |> to_optdef
  end
;;

let fetch
  ?headers
  ?body
  ?mode
  ?credentials
  ?cache
  ?redirect
  ?referrer
  ?referrer_policy
  ?integrity
  ?keepalive
  ~method_
  target
  =
  let options =
    make_options
      method_
      headers
      body
      mode
      credentials
      cache
      redirect
      referrer
      referrer_policy
      integrity
      keepalive
  in
  let target = Js.string target in
  Js.Unsafe.fun_call
    (Js.Unsafe.js_expr "fetch")
    [| Js.Unsafe.inject target; Js.Unsafe.inject options |]
  |> Promise.as_lwt
;;

let get = fetch ~method_:`GET ?body:None
let head = fetch ~method_:`HEAD ?body:None
