open Tyxml.Html
open Nightmare_tyxml

let home _request =
  Template.default
    ~example_title:"Examples index"
    ~example_subtitle:"Set of implemented examples"
    ~title:"Index"
    ~page_title:"A list of examples"
    ~page_subtitle:"A more or less organised list of examples using Nightmare"
    ~links:[]
    [ ul
        [ li [ a_of Endpoint.Simple_routing.home [ txt "Simple routing" ] ]
        ; li
            [ a_of
                Endpoint.Counter_vdom.home
                [ txt "The classical counter using VDom" ]
            ]
        ]
    ; script
        (txt
           "nightmare_js.suspend(function () { \
            nightmare_example.helloToConsole('visitor'); });")
    ]
;;

module Simple_routing = struct
  open struct
    open Endpoint.Simple_routing

    let page =
      Template.default
        ~example_title:"Simple routing"
        ~example_subtitle:"A very simple example of routing using services"
        ~links:
          [ a_of Endpoint.home [ txt "Index" ]
          ; a_of home [ txt "Home" ]
          ; a_of hello "Alice" [ txt "Say hello to Alice" ]
          ; a_of about [ txt "About" ]
          ]
    ;;
  end

  let home _request =
    page
      ~title:"Home"
      ~page_title:"Welcome to your Nightmare App"
      ~page_subtitle:"This is the entry point of the application"
      [ p
          [ txt
              "You are on a very simple page that simply demonstrates the use \
               of services to build a router and links between pages."
          ]
      ]
  ;;

  let about _request =
    page
      ~title:"About"
      ~page_title:"About your Nightmare App"
      ~page_subtitle:"More information about this example"
      [ p
          [ txt
              "You are on a very simple page that simply demonstrates the use \
               of services to build a router and links between pages."
          ]
      ; p [ txt "This example uses these different libraries:" ]
      ; ul
          [ li
              [ a_of
                  Endpoint.External.github_repository
                  "aantron"
                  "dream"
                  [ txt "Dream" ]
              ; span [ txt " - As a low-level web framework" ]
              ]
          ; li
              [ a_of
                  Endpoint.External.github_repository
                  "ocsigen"
                  "tyxml"
                  [ txt "TyXML" ]
              ; span [ txt " - To build statically validated HTML nodes" ]
              ]
          ; li
              [ a_of
                  Endpoint.External.github_repository
                  "funkywork"
                  "nightmare"
                  [ txt "Nightmare.service, Nightmare-dream and Nightmare-tyxml"
                  ]
              ; span
                  [ txt
                      " - To describe the services and provide the glue \
                       between Dream, TyXML and Nightmare"
                  ]
              ]
          ]
      ]
  ;;

  let hello name _request =
    let open Endpoint.Simple_routing in
    page
      ~title:"Hello"
      ~page_title:("Hello " ^ name)
      ~page_subtitle:
        ("We are really glad to see you, " ^ name ^ ", on this page!")
      [ p
          [ span
              [ txt
                  "You can use the URL to change the person to greet! For \
                   example, you can click on the links below if you want to \
                   say Hello to someone other than "
              ]
          ; strong [ txt name ]
          ; span [ txt "." ]
          ]
      ; ul
          [ li [ a_of hello "Bob" [ txt "Say hello to Bob" ] ]
          ; li [ a_of hello "Carol" [ txt "Say hello to Carol" ] ]
          ]
      ]
  ;;
end

module Counter_vdom = struct
  open struct
    open Endpoint.Counter_vdom

    let page =
      Template.default
        ~example_title:"Simple counter using VDom"
        ~example_subtitle:"A very simple example of counter using VDom"
        ~links:
          [ a_of Endpoint.home [ txt "Index" ]
          ; a_of home [ txt "Home" ]
          ; a_of about [ txt "About" ]
          ]
    ;;
  end

  let home _request =
    page
      ~title:"Home"
      ~page_title:"Welcome to your Nightmare App"
      ~page_subtitle:"This is the entry point of the application"
      [ p
          [ txt
              "You are on a very simple page that simply demonstrates the use \
               of services to build a router and links between pages."
          ]
      ; div ~a:[ a_id "simple-counter-app" ] [ txt "Loading the application" ]
      ; script
          (txt
             {js|
             nightmare_js.suspend(function(){
               nightmare_example.mountCounterVdom('simple-counter-app');
             });|js})
      ]
  ;;

  let about _request =
    page
      ~title:"About"
      ~page_title:"About your Nightmare App"
      ~page_subtitle:"More information about this example"
      [ p
          [ txt
              "This is a very simple example that mounts an application in a \
               div described using ocaml-vdom."
          ]
      ; p [ txt "This example uses these different libraries:" ]
      ; ul
          [ li
              [ a_of
                  Endpoint.External.github_repository
                  "aantron"
                  "dream"
                  [ txt "Dream" ]
              ; span [ txt " - As a low-level web framework" ]
              ]
          ; li
              [ a_of
                  Endpoint.External.github_repository
                  "ocsigen"
                  "tyxml"
                  [ txt "TyXML" ]
              ; span [ txt " - To build statically validated HTML nodes" ]
              ]
          ; li
              [ a_of
                  Endpoint.External.github_repository
                  "lexifi"
                  "ocaml-vdom"
                  [ txt "OCaml-VDom" ]
              ; span [ txt " - To build a SPA using Virtual DOM" ]
              ]
          ; li
              [ a_of
                  Endpoint.External.github_repository
                  "funkywork"
                  "nightmare"
                  [ txt
                      "Nightmare.service, Nightmare-dream and Nightmare-tyxml \
                       and Nightmare_js-vdom"
                  ]
              ; span
                  [ txt
                      " - To describe the services and provide the glue \
                       between Dream, TyXML and Nightmare"
                  ]
              ]
          ]
      ]
  ;;
end
