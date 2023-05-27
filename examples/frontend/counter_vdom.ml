type model = int

type message =
  | Increment
  | Decrement

let update model = function
  | Increment -> model + 1
  | Decrement -> model - 1
;;

let view model =
  let open Nightmare_js_vdom in
  div
    ~a:[ a_class [ "counter-application" ] ]
    [ span [ button ~a:[ on_click (fun _ -> Decrement) ] [ txt "-" ] ]
    ; samp [ txt @@ string_of_int model ]
    ; span [ button ~a:[ on_click (fun _ -> Increment) ] [ txt "+" ] ]
    ]
;;

let init = 0
let app = Nightmare_js_vdom.simple_app ~init ~update ~view ()
