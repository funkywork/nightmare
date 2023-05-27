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

module Internal = struct
  external construct
    :  (('a -> unit) -> (error -> unit) -> unit)
    -> 'a t
    = "caml_construct_promise"

  external resolved : 'a -> 'a t = "caml_resolve_promise"
  external then_ : 'a t -> ('a -> 'b t) -> 'b t = "caml_then_promise"
  external catch : 'a t -> (error -> 'a t) -> 'a t = "caml_catch_promise"
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
let catch handler promise = Internal.catch promise handler
