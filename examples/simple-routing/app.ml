(* A very simple example of routing using services. *)

let router =
  Nightmare_dream.router
    ~services:[ Service.root; Service.about; Service.hello ]
;;

let () = Dream.run ~port:4000 @@ Dream.logger @@ router @@ Common.Router.static
