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

let start f =
  let open Lwt.Syntax in
  let* _ = Js_of_ocaml_lwt.Lwt_js_events.onload () in
  let+ () = f () in
  ()
;;

let context =
  object%js (self)
    val nightmare_internal =
      object%js
        val suspending = Js.array [||]
      end

    method suspend f = self##.nightmare_internal##.suspending##push f |> ignore

    method mount =
      let suspension =
        self##.nightmare_internal##.suspending
        |> Js.to_array
        |> Array.fold_left
             (fun chain task () ->
               let open Lwt.Syntax in
               let+ () = chain () in
               Js.Unsafe.fun_call task [||])
             (fun () -> Lwt.return_unit)
      in
      start suspension
  end
;;

let allow () = Js.export "nightmare_js" context
