(* A very simple example of routing using services. *)

let router =
  Nightmare_dream.router
    ~services:
      [ Service.home
      ; Service.Simple_routing.home
      ; Service.Simple_routing.about
      ; Service.Simple_routing.hello
      ; Service.Counter_vdom.home
      ; Service.Counter_vdom.about
      ]
;;

let static_path =
  let open Dream in
  router [ get "/priv/**" @@ static "examples/priv/" ]
;;

let () = Dream.run ~port:8888 @@ Dream.logger @@ router @@ static_path
