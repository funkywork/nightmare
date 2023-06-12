open Nightmare_service.Service

type t = Nightmare_dream.service

let home : t = straight ~endpoint:Shared.Endpoint.home Page.home

module Simple_routing = struct
  let home : t =
    straight
      ~endpoint:Shared.Endpoint.Simple_routing.home
      Page.Simple_routing.home
  ;;

  let about : t =
    straight
      ~endpoint:Shared.Endpoint.Simple_routing.about
      Page.Simple_routing.about
  ;;

  let hello : t =
    straight
      ~endpoint:Shared.Endpoint.Simple_routing.hello
      Page.Simple_routing.hello
  ;;
end

module Counter_vdom = struct
  let home : t =
    straight ~endpoint:Shared.Endpoint.Counter_vdom.home Page.Counter_vdom.home
  ;;

  let about : t =
    straight
      ~endpoint:Shared.Endpoint.Counter_vdom.about
      Page.Counter_vdom.about
  ;;
end

module Server_side_counter = struct
  let session_key = "ssc-current-value"

  let home : t =
    straight
      ~endpoint:Shared.Endpoint.Server_side_counter.home
      Page.Server_side_counter.home
  ;;

  let about : t =
    straight
      ~endpoint:Shared.Endpoint.Server_side_counter.about
      Page.Server_side_counter.about
  ;;

  let value : t =
    straight ~endpoint:Shared.Endpoint.Server_side_counter.value (fun request ->
      Dream.respond
      @@
      match Dream.session_field request session_key with
      | Some x -> x
      | None -> "0")
  ;;

  let operation f request =
    let value =
      Dream.session_field request session_key
      |> fun x -> Option.bind x int_of_string_opt
    in
    let value = f @@ Option.value ~default:0 value |> string_of_int in
    let open Lwt.Syntax in
    let* () = Dream.set_session_field request session_key value in
    Dream.respond "done"
  ;;

  let increment : t =
    straight
      ~endpoint:Shared.Endpoint.Server_side_counter.increment
      (operation succ)
  ;;

  let decrement : t =
    straight
      ~endpoint:Shared.Endpoint.Server_side_counter.decrement
      (operation pred)
  ;;
end
