open Nightmare_service.Endpoint

let home () = get root
let priv () = get @@ (~/"priv" /: string)

module Simple_routing = struct
  let home () = get ~/"simple-routing"
  let about () = get (~/"simple-routing" / "about")
  let hello () = get (~/"simple-routing" / "hello" /: string)
end

module Counter_vdom = struct
  let home () = get ~/"counter-vdom"
  let about () = get (~/"counter-vdom" / "about")
end

module Server_side_counter = struct
  let home () = get ~/"server-side-counter"
  let about () = get (~/"server-side-counter" / "about")
  let value () = get (~/"server-side-counter" / "get")
  let increment () = post (~/"server-side-counter" / "incr")
  let decrement () = post (~/"server-side-counter" / "decr")
end

module External = struct
  let ocaml_v2 action path = outer action "https://v2.ocaml.org/" path
  let ocaml_org () = outer get "https://ocaml.org" root

  let ocaml_logo () =
    ocaml_v2 get (~/"releases" / "5.0" / "htmlman" / "colour-logo.svg")
  ;;

  let github_repository () = outer get "https://github.com" (~/:string /: string)
end
