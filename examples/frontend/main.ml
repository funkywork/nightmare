open Js_of_ocaml
open Nightmare_js

let () = Suspension.allow ()

let () =
  Js.export
    "nightmare_example"
    (object%js
       (* A simple example of Js Exportation to suspension.  *)
       method helloToConsole message =
         let message = "Hello, " ^ Js.to_string message ^ " !" in
         Console.(string log) message
    end)
;;
