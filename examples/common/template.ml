let page ?(use_nightmare_js = false) ~title content =
  let page_title = "Nightmare example -" ^ title in
  let open Tyxml.Html in
  let open Nightmare_tyxml in
  let node_title = title (txt page_title) in
  let body_content =
    if use_nightmare_js
    then content @ [ script @@ txt "nightmare_js.mount();" ]
    else content
  in
  let css = link_of ~rel:[ `Stylesheet ] Endpoint.asset "default.css" in
  let head_content =
    if use_nightmare_js
    then [ css; script_of Endpoint.asset "index.bc.js" "" ]
    else [ css ]
  in
  html ~a:[ a_lang "en" ] (head node_title head_content) (body body_content)
;;

let default
  ?use_nightmare_js
  ~title
  ~example_title
  ~example_subtitle
  ~page_title
  ~page_subtitle
  ~links
  content
  =
  let doc_title = title in
  let open Tyxml.Html in
  let open Nightmare_tyxml in
  page
    ?use_nightmare_js
    ~title:doc_title
    [ header
        [ main [ h1 [ txt example_title ]; h2 [ txt example_subtitle ] ]
        ; nav [ ul (List.map (fun l -> li [ l ]) links) ]
        ]
    ; main (h1 [ txt page_title ] :: h2 [ txt page_subtitle ] :: content)
    ; footer
        [ div
            [ span [ txt "Proudly powered by" ]
            ; br ()
            ; a_of Endpoint.ocaml_org [ img_of Endpoint.ocaml_logo ]
            ]
        ]
    ]
  |> Format.asprintf "%a" (Tyxml.Html.pp ())
  |> Dream.html
;;
