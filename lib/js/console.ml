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

let console = Bindings.get_console ()
let clear () = console##clear
let log value = console##log value
let debug value = console##debug value
let info value = console##info value
let warning value = console##warn value
let error value = console##error value
let dir value = console##dir value
let dir_xml node = console##dirxml node
let trace () = console##trace
let string handler str = handler (Js.string str)

let assert' ?message ?payload flag =
  let flag = Js.bool flag in
  match Stdlib.Option.map Js.string message, payload with
  | Some message, Some payload -> console##assert_2 flag message payload
  | Some x, None -> console##assert_1 flag x
  | None, Some x ->
    (* Not grouped to deal with payload as a generic value *)
    console##assert_1 flag x
  | None, None -> console##assert_ flag
;;

let table ?columns obj =
  let columns =
    columns
    |> Stdlib.Option.map (Util.from_list_to_js_array Js.string)
    |> Js.Optdef.option
  in
  console##table obj columns
;;

let default_label = "default"
let default_label_js = Js.string default_label

let make_label = function
  | None -> default_label_js
  | Some x -> Js.string x
;;

module Timer = struct
  let default_label = default_label
  let start ?label () = console##time (make_label label)
  let stop ?label () = console##timeEnd (make_label label)

  let log ?label ?payload () =
    let payload = Js.Optdef.option payload in
    console##timeLog (make_label label) payload
  ;;
end

module Counter = struct
  let default_label = default_label
  let tick ?label () = console##count (Js.Optdef.return @@ make_label label)

  let reset ?label () =
    console##countReset (Js.Optdef.return @@ make_label label)
  ;;
end

module Indent = struct
  let increase ?(collapsed = false) ?label () =
    let label = label |> Stdlib.Option.map Js.string |> Js.Optdef.option in
    if collapsed then console##groupCollapsed label else console##group label
  ;;

  let decrease () = console##groupEnd
end
