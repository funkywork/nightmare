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

       (* Mount the Counter Example *)
       method mountCounterVdom id =
         let id = Js.to_string id in
         Nightmare_js_vdom.mount_to ~id (fun _ ->
           let () = Console.(string info) @@ "Mounting " ^ id in
           let app = Counter_vdom.app () in
           Lwt.return app)

       (* Mount the Server Side counter example *)
       method mountServerCounterVdom id =
         let id = Js.to_string id in
         Nightmare_js_vdom.mount_to ~id (fun _ ->
           let () = Console.(string info) @@ "Mounting " ^ id in
           let app = Server_counter_vdom.app () in
           Lwt.return app)
    end)
;;
