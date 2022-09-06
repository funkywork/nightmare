(*  MIT License

    Copyright (c) 2022 funkywork

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

type t =
  [ `GET
  | `POST
  | `PUT
  | `DELETE
  | `HEAD
  | `CONNECT
  | `OPTIONS
  | `TRACE
  | `PATCH
  ]

type for_link = [ `GET ]

type for_form_action =
  [ `GET
  | `POST
  ]

let equal a b =
  match (a :> t), (b :> t) with
  | `GET, `GET -> true
  | `POST, `POST -> true
  | `PUT, `PUT -> true
  | `DELETE, `DELETE -> true
  | `HEAD, `HEAD -> true
  | `CONNECT, `CONNECT -> true
  | `OPTIONS, `OPTIONS -> true
  | `TRACE, `TRACE -> true
  | `PATCH, `PATCH -> true
  | _, _ -> false
;;

let pp ppf = function
  | `GET -> Format.fprintf ppf "GET"
  | `POST -> Format.fprintf ppf "POST"
  | `PUT -> Format.fprintf ppf "PUT"
  | `DELETE -> Format.fprintf ppf "DELETE"
  | `HEAD -> Format.fprintf ppf "HEAD"
  | `CONNECT -> Format.fprintf ppf "CONNECT"
  | `OPTIONS -> Format.fprintf ppf "OPTIONS"
  | `TRACE -> Format.fprintf ppf "TRACE"
  | `PATCH -> Format.fprintf ppf "PATCH"
;;

let to_string x = Format.asprintf "%a" pp x

let from_string str =
  match String.(trim @@ lowercase_ascii str) with
  | "get" -> Some (`GET :> t)
  | "post" -> Some `POST
  | "put" -> Some `PUT
  | "delete" -> Some `DELETE
  | "head" -> Some `HEAD
  | "connect" -> Some `CONNECT
  | "options" -> Some `OPTIONS
  | "trace" -> Some `TRACE
  | "patch" -> Some `PATCH
  | _ -> None
;;

let all =
  [ `GET; `POST; `PUT; `DELETE; `HEAD; `CONNECT; `OPTIONS; `TRACE; `PATCH ]
;;
