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

type +'a t
type error

exception Promise_rejection of error

module Internal = struct
  external construct
    :  (('a -> unit) -> (error -> unit) -> unit)
    -> 'a t
    = "caml_construct_promise"

  external resolved : 'a -> 'a t = "caml_resolve_promise"
  external then_ : 'a t -> ('a -> 'b t) -> 'b t = "caml_then_promise"

  external then_with
    :  'a t
    -> ('a -> 'b t)
    -> (error -> 'b t)
    -> 'b t
    = "caml_then_with_rejection"

  external catch : 'a t -> (error -> 'a t) -> 'a t = "caml_catch_promise"
  external set_timeout : int -> unit t = "caml_set_timeout_promise"
end

let pending_with_rejection () =
  let resolver = ref ignore
  and rejecter = ref ignore in
  let promise =
    Internal.construct (fun resolve reject ->
      let () = resolver := resolve in
      rejecter := reject)
  in
  promise, !resolver, !rejecter
;;

let pending () =
  let promise, resolver, _ = pending_with_rejection () in
  promise, resolver
;;

let resolved x = Internal.resolved x
let then_ handler promise = Internal.then_ promise handler
let then' resolve reject promise = Internal.then_with promise resolve reject
let catch handler promise = Internal.catch promise handler

let as_lwt promise =
  let lwt_promise, resolver = Lwt.wait () in
  let resolve value =
    let () = Lwt.wakeup_later resolver value in
    resolved ()
  and reject error =
    let () = Lwt.wakeup_later_exn resolver (Promise_rejection error) in
    resolved ()
  in
  let _ = then' resolve reject promise in
  lwt_promise
;;

let set_timeout duration = Internal.set_timeout duration

module Monad = Preface.Make.Monad.Via_return_and_bind (struct
  type nonrec 'a t = 'a t

  let return x = resolved x
  let bind f x = then_ f x
end)

module Applicative = Preface.Make.Applicative.From_monad (Monad)
module Functor = Applicative
