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

module Href = struct
  type t =
    { fragments : string list
    ; query_string : string option
    ; anchor : string option
    }

  let make ?query_string ?anchor fragments = { fragments; query_string; anchor }
  let fragments { fragments; _ } = fragments
  let query_string { query_string; _ } = query_string
  let anchor { anchor; _ } = anchor

  let extract_at chr str =
    match String.split_on_char chr str with
    | [ ""; "" ] -> None, None
    | [ ""; x ] -> None, Some x
    | [ x; "" ] -> Some x, None
    | [ x; y ] -> Some x, Some y
    | [ "" ] -> None, None
    | [ x ] -> Some x, None
    | _ -> None, None
  ;;

  let extract_anchor = extract_at '#'

  let extract_query_string = function
    | None -> None, None
    | Some tl -> extract_at '?' tl
  ;;

  let split_fragments str =
    match String.split_on_char '/' str with
    | "" :: "" :: fragments | "" :: fragments | fragments -> fragments
  ;;

  let extract_fragments = function
    | None -> []
    | Some x -> split_fragments x
  ;;

  let from_string str =
    let tl, anchor = extract_anchor str in
    let tl, query_string = extract_query_string tl in
    let fragments = extract_fragments tl in
    make ?query_string ?anchor fragments
  ;;

  let pp ppf { fragments; query_string; anchor } =
    let anchor = Option.fold ~none:"" ~some:(fun x -> "#" ^ x) anchor
    and querys = Option.fold ~none:"" ~some:(fun x -> "?" ^ x) query_string
    and fragmt = String.concat "/" fragments in
    Format.fprintf ppf "/%s%s%s" fragmt querys anchor
  ;;

  let equal
    { fragments = f_a; query_string = q_a; anchor = a_a }
    { fragments = f_b; query_string = q_b; anchor = a_b }
    =
    List.equal String.equal f_a f_b
    && Option.equal String.equal q_a q_b
    && Option.equal String.equal a_a a_b
  ;;
end
