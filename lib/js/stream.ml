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

module Reader = struct
  type 'a t = 'a Bindings.readable_stream_default_reader Js.t

  let is_closed r = r##.closed |> Js.to_bool

  let cancel ?reason r =
    let reason = Optional.Option.(Js.string <$> reason |> to_optdef) in
    r##cancel reason |> Promise.as_lwt
  ;;

  let close r = r##close |> Promise.as_lwt

  let read r =
    let open Lwt.Syntax in
    let+ result = r##read |> Promise.as_lwt in
    let is_done = result##._done |> Js.to_bool
    and value = result##.value in
    is_done, value
  ;;

  let decoder =
    let constr = Js.Unsafe.global##.__TextDecoder in
    new%js constr
  ;;

  let read_string r =
    let open Lwt.Syntax in
    let+ is_done, result = read r in
    let str_result = decoder##decode result in
    is_done, str_result |> Js.to_string
  ;;

  let release_lock r = r##releaseLock
end

module Readable = struct
  type 'a t = 'a Bindings.readable_stream Js.t

  let is_locked s = s##.locked |> Js.to_bool

  let cancel ?reason s =
    let reason = Optional.Option.(Js.string <$> reason |> to_optdef) in
    s##cancel reason |> Promise.as_lwt
  ;;

  let get_reader s = s##getReader
end
