open Js_of_ocaml
open Nightmare_js

let () = Suspension.allow ()
let () = Console.log (Promise.resolved 10)

let () =
  Js.export
    "nightmare_example"
    (object%js
       (* A simple example of Js Exportation to suspension.  *)
       method helloToConsole message =
         let message = "Hello, " ^ Js.to_string message ^ " !" in
         Console.(string log) message

       (* Mount the Counter Example *)
       method mountCounterVdom id =
         let id = Js.to_string id in
         Nightmare_js_vdom.mount_to ~id (fun _ ->
           let () = Console.(string info) @@ "Mounting " ^ id in
           Lwt.return Counter_vdom.app)
    end)
;;
