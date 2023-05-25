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
let br ?key ?a () = elt "br" ?key ?a []
let hr ?key ?a () = elt "hr" ?key ?a []
let button ?key ?a children = elt "button" ?key ?a children
let canvas ?key ?a children = elt "canvas" ?key ?a children
let caption ?key ?a children = elt "caption" ?key ?a children
let cite ?key ?a children = elt "cite" ?key ?a children
let code ?key ?a children = elt "code" ?key ?a children
let col ?key ?a () = elt "col" ?key ?a []
let colgroup ?key ?a children = elt "colgroup" ?key ?a children
let datalist ?key ?a children = elt "datalist" ?key ?a children
let dd ?key ?a children = elt "dd" ?key ?a children
let del ?key ?a children = elt "del" ?key ?a children
let ins ?key ?a children = elt "del" ?key ?a children
let details ?key ?a children = elt "details" ?key ?a children
let dfn ?key ?a children = elt "dfn" ?key ?a children
let dialog ?key ?a children = elt "dialog" ?key ?a children
let dl ?key ?a children = elt "dl" ?key ?a children
let dt ?key ?a children = elt "dt" ?key ?a children
let em ?key ?a children = elt "em" ?key ?a children
let embed ?key ?a () = elt "embed" ?key ?a []

let fieldset ?legend ?key ?a children =
  let children =
    Option.fold ~none:children ~some:(fun x -> x :: children) legend
  in
  elt "fieldset" ?key ?a children
;;

let figcaption ?key ?a children = elt "figcaption" ?key ?a children

let figure ?figcaption ?key ?a children =
  let children =
    Option.fold
      ~none:children
      ~some:(function
        | `Top x -> x :: children
        | `Bottom x -> children @ [ x ])
      figcaption
  in
  elt "figure" ?key ?a children
;;

let footer ?key ?a children = elt "footer" ?key ?a children
let form ?key ?a children = elt "form" ?key ?a children
let h1 ?key ?a children = elt "h1" ?key ?a children
let h2 ?key ?a children = elt "h2" ?key ?a children
let h3 ?key ?a children = elt "h3" ?key ?a children
let h4 ?key ?a children = elt "h4" ?key ?a children
let h5 ?key ?a children = elt "h5" ?key ?a children
let h6 ?key ?a children = elt "h6" ?key ?a children
let header ?key ?a children = elt "header" ?key ?a children
let hgroup ?key ?a children = elt "hgroup" ?key ?a children
let i ?key ?a children = elt "i" ?key ?a children
let iframe ?key ?a children = elt "iframe" ?key ?a children

let img ~src ~alt ?key ?(a = []) () =
  let a =
    Attrib.a_src src
    :: Attrib.a_alt alt
    :: (a
         : ([< Html_types.img_attrib ], 'msg) Attrib.t list
         :> ([> Html_types.img_attrib | `Src | `Alt ], 'msg) Attrib.t list)
  in
  elt "img" ?key ~a []
;;

let input ?key ?a () = elt "input" ?key ?a []
let kbd ?key ?a children = elt "kbd" ?key ?a children
let label ?key ?a children = elt "label" ?key ?a children
let legend ?key ?a children = elt "legend" ?key ?a children
let li ?key ?a children = elt "li" ?key ?a children
