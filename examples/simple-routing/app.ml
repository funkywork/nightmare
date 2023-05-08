(* A very simple example of routing using services. *)

let router =
  Nightmare_dream.router
    ~services:[ Service.root; Service.about; Service.hello ]
;;

let static_path =
  let open Dream in
  router [ get "/priv/**" @@ static "examples/priv/" ]
;;

let () = Dream.run ~port:8888 @@ Dream.logger @@ router @@ static_path
