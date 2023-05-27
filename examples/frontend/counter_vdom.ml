type model = int
type 'msg Vdom.Cmd.t += Delayed of 'msg

let register () =
  let open Vdom_blit in
  let handler =
    { Cmd.f =
        (fun ctx -> function
          | Delayed message ->
            let () =
              Lwt.async (fun () ->
                let open Lwt.Syntax in
                let+ () = Nightmare_js.Promise.(set_timeout 3000 |> as_lwt) in
                Cmd.send_msg ctx message)
            in
            true
          | _ -> false)
    }
  in
  register @@ cmd handler
;;

type message =
  | Increment
  | Decrement
  | Ask_for_delayed_increment
  | Ask_for_delayed_decrement

let update (_, value) = function
  | Increment -> Vdom.return @@ (false, value + 1)
  | Decrement -> Vdom.return @@ (false, value - 1)
  | Ask_for_delayed_increment ->
    Vdom.return ~c:[ Delayed Increment ] (true, value)
  | Ask_for_delayed_decrement ->
    Vdom.return ~c:[ Delayed Decrement ] (true, value)
;;

let view (is_disabled, value) =
  let open Nightmare_js_vdom in
  div
    ~a:[ a_class [ "counter-application" ] ]
    [ span
        [ button
            ~a:
              [ a_disabled is_disabled
              ; on_click (fun _ -> Ask_for_delayed_decrement)
              ]
            [ txt "- slow" ]
        ]
    ; span
        [ button
            ~a:[ a_disabled is_disabled; on_click (fun _ -> Decrement) ]
            [ txt "-" ]
        ]
    ; samp
        [ (txt
           @@
           if is_disabled
           then "This is a voluntary slow action"
           else string_of_int value)
        ]
    ; span
        [ button
            ~a:[ a_disabled is_disabled; on_click (fun _ -> Increment) ]
            [ txt "+" ]
        ]
    ; span
        [ button
            ~a:
              [ a_disabled is_disabled
              ; on_click (fun _ -> Ask_for_delayed_increment)
              ]
            [ txt "+ slow" ]
        ]
    ]
;;

let init = Vdom.return (false, 0)

let app () =
  let () = register () in
  Nightmare_js_vdom.app ~init ~update ~view ()
;;
