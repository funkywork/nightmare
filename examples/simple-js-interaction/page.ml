open Tyxml.Html
open Nightmare_tyxml

open struct
  let page =
    Common.Template.default
      ~example_title:"Simple routing"
      ~example_subtitle:"A very simple example of routing using services"
      ~links:
        [ a_of Endpoint.root [ txt "Home" ]
        ; a_of Endpoint.about [ txt "About" ]
        ]
  ;;

  let suspend action =
    script (txt @@ "nightmare_js.suspend(function() { " ^ action ^ " });")
  ;;
end

let root _request =
  page
    ~title:"Home"
    ~use_nightmare_js:true
    ~page_title:"Welcome to your Nightmare App"
    ~page_subtitle:"This is the entry point of the application"
    [ p
        [ txt
            "You are on a very simple page that simply demonstrates the use of \
             JavaScript (through Nightmare_js)."
        ]
    ; suspend "console.log(1);"
    ; suspend "console.log(2);"
    ; suspend "console.log(3);"
    ; script (txt "console.log(4); ")
    ]
;;
