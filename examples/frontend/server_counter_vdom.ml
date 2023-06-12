type model = int

type 'msg Vdom.Cmd.t +=
  | Increment of 'msg
  | Decrement of 'msg
  | Get_value of (int -> 'msg)

type message =
  | Ask_for_increment
  | Ask_for_decrement
  | Ask_for_value
  | Replace_value of int

let update value = function
  | Ask_for_increment -> Vdom.return ~c:[ Increment Ask_for_value ] value
  | Ask_for_decrement -> Vdom.return ~c:[ Decrement Ask_for_value ] value
  | Ask_for_value ->
    Vdom.return ~c:[ Get_value (fun x -> Replace_value x) ] value
  | Replace_value x -> Vdom.return x
;;

let view value =
  let open Nightmare_js_vdom in
  div
    ~a:[ a_class [ "counter-application" ] ]
    [ span
        [ button
            ~a:[ on_click (fun _ -> Ask_for_decrement) ]
            [ txt " (server) -" ]
        ]
    ; samp [ txt @@ string_of_int value ]
    ; span
        [ button
            ~a:[ on_click (fun _ -> Ask_for_increment) ]
            [ txt "+ (server)" ]
        ]
    ]
;;

let init = Vdom.return ~c:[ Get_value (fun x -> Replace_value x) ] 0

open struct
  open Nightmare_service.Endpoint

  let value () = get (~/"server-side-counter" / "get")
  let increment () = post (~/"server-side-counter" / "incr")
  let decrement () = post (~/"server-side-counter" / "decr")
end

let register () =
  let open Vdom_blit in
  let handler =
    { Cmd.f =
        (fun ctx -> function
          | Increment msg ->
            let () =
              Lwt.async (fun () ->
                let open Lwt.Syntax in
                let+ _ = Nightmare_js.Fetch.from increment in
                Cmd.send_msg ctx msg)
            in
            true
          | Decrement msg ->
            let () =
              Lwt.async (fun () ->
                let open Lwt.Syntax in
                let+ _ = Nightmare_js.Fetch.from decrement in
                Cmd.send_msg ctx msg)
            in
            true
          | Get_value handler ->
            let () =
              Lwt.async (fun () ->
                let open Lwt.Syntax in
                let* response = Nightmare_js.Fetch.from value in
                let+ text = Nightmare_js.Fetch.Response.text response in
                let result = Option.value ~default:0 (int_of_string_opt text) in
                Cmd.send_msg ctx (handler result))
            in
            true
          | _ -> false)
    }
  in
  register @@ cmd handler
;;

let app () =
  let () = register () in
  Nightmare_js_vdom.app ~init ~update ~view ()
;;
