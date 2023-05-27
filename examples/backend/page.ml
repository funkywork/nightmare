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
    [ ul [ li [ a_of Endpoint.Simple_routing.home [ txt "Simple routing" ] ] ] ]
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
                  [ txt "Nightmare.Service, Nightmare_dream and Nightmare_tyxml"
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
