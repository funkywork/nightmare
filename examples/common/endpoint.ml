open Nightmare_service.Endpoint

let ocaml_v2 action path = outer action "https://v2.ocaml.org/" path
let ocaml_org () = outer get "https://ocaml.org" root

let ocaml_logo () =
  ocaml_v2 get (~/"releases" / "5.0" / "htmlman" / "colour-logo.svg")
;;

let github_repository () = outer get "https://github.com" (~/:string /: string)
