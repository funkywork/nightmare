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

type (_, +'msg) t = 'msg Vdom.vdom

type ('attrib, 'result, 'msg) leaf =
  ?key:string -> ?a:('attrib, 'msg) Attrib.t list -> unit -> ('result, 'msg) t

type ('attrib, 'children, 'result, 'msg) one =
  ?key:string -> ?a:('attrib, 'msg) Attrib.t list -> unit -> ('result, 'msg) t

type ('attrib, 'children, 'result, 'msg) many =
  ?key:string
  -> ?a:('attrib, 'msg) Attrib.t list
  -> ('children, 'msg) t list
  -> ('result, 'msg) t

let remove_node_kind x = x

let elt tag ?key ?a children =
  let a = Option.map Attrib.remove_attribute_kinds a in
  Vdom.elt tag ?key ?a children
;;

let txt ?key value = Vdom.text ?key value
let div ?key ?a children = elt "div" ?key ?a children
let a ?key ?a children = elt "a" ?key ?a children
let abbr ?key ?a children = elt "abbr" ?key ?a children
let address ?key ?a children = elt "address" ?key ?a children
let area ?key ?a () = elt "area" ?key ?a []
let article ?key ?a children = elt "article" ?key ?a children
let aside ?key ?a children = elt "aside" ?key ?a children

let audio ?src ?(srcs = []) ?key ?(a = []) children =
  let children = srcs @ children in
  let a =
    (a
      : ([< Html_types.audio_attrib ], 'msg) Attrib.t list
      :> ([> Html_types.audio_attrib ], 'msg) Attrib.t list)
  in
  let a = Option.fold ~none:a ~some:(fun x -> Attrib.a_src x :: a) src in
  elt "audio" ?key ~a children
;;

let video ?src ?(srcs = []) ?key ?(a = []) children =
  let children = srcs @ children in
  let a =
    (a
      : ([< Html_types.video_attrib ], 'msg) Attrib.t list
      :> ([> Html_types.video_attrib ], 'msg) Attrib.t list)
  in
  let a = Option.fold ~none:a ~some:(fun x -> Attrib.a_src x :: a) src in
  elt "video" ?key ~a children
;;

let b ?key ?a children = elt "b" ?key ?a children
let base ?key ?a () = elt "base" ?key ?a []

let bdi ~dir ?key ?(a = []) children =
  let a = Attrib.a_dir dir :: a in
  elt "bdi" ?key ~a children
;;

let bdo ~dir ?key ?(a = []) children =
  let a = Attrib.a_dir dir :: a in
  elt "bdo" ?key ~a children
;;

let blockquote ?key ?a children = elt "blockquote" ?key ?a children
