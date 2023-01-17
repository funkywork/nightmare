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

module MString = Map.Make (String)

type status =
  | Ok of string
  | Redirect of string
  | Error of string

let eq_status x y =
  match x, y with
  | Ok x, Ok y | Redirect x, Redirect y | Error x, Error y -> String.equal x y
  | _ -> false
;;

let pp_status ppf = function
  | Ok x -> Format.fprintf ppf "Ok %s" x
  | Redirect x -> Format.fprintf ppf "Redirect to %s" x
  | Error x -> Format.fprintf ppf "Error %s" x
;;

type t =
  { status : status
  ; env : string MString.t
  }

let status_of { status; _ } = status

let make ?(env = []) status =
  let env =
    List.fold_left (fun map (k, v) -> MString.add k v map) MString.empty env
  in
  { env; status }
;;

let make_ok ?env content = make ?env (Ok content)
let make_error ?env content = make ?env (Error content)
let make_redirect ?env content = make ?env (Redirect content)
let get_var ~key { env; _ } = MString.find_opt key env

let add_var ~key ~value ({ env; _ } as req) =
  { req with env = MString.add key value env }
;;

let remove_var ~key ({ env; _ } as req) =
  { req with env = MString.remove key env }
;;

let clean_var req = { req with env = MString.empty }
let redirect url req = { req with status = Redirect url }
let error error req = { req with status = Error error }
let ok content req = { req with status = Ok content }

let equal { status = status_a; env = env_a } { status = status_b; env = env_b } =
  eq_status status_a status_b && MString.equal String.equal env_a env_b
;;

let pp_tuple ppf (k, v) = Format.fprintf ppf "['%s'] -> '%s';" k v

let pp_env ppf env =
  let env = MString.to_seq env |> List.of_seq in
  Format.fprintf ppf "[%a]" (Format.pp_print_list pp_tuple) env
;;

let pp ppf { status; env } =
  Format.fprintf ppf "{status = %a; env = %a}" pp_status status pp_env env
;;

let testable = Alcotest.testable pp equal
