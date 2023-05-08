let page ~title content =
  let page_title = "Nightmare example -" ^ title in
  let open Tyxml.Html in
  let node_title = title (txt page_title) in
  html
    ~a:[ a_lang "en" ]
    (head node_title [ link ~rel:[ `Stylesheet ] ~href:"/priv/default.css" () ])
    (body content)
;;

let default
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
