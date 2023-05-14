(* A very simple example of interacting with JavaScript. *)

let router = Nightmare_dream.router ~services:[ Service.root ]
let () = Dream.run ~port:4000 @@ Dream.logger @@ router @@ Common.Router.static
