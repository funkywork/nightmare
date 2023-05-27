open Nightmare_service.Service

type t = Nightmare_dream.service

let home : t = straight ~endpoint:Endpoint.home Page.home

module Simple_routing = struct
  let home : t =
    straight ~endpoint:Endpoint.Simple_routing.home Page.Simple_routing.home
  ;;

  let about : t =
    straight ~endpoint:Endpoint.Simple_routing.about Page.Simple_routing.about
  ;;

  let hello : t =
    straight ~endpoint:Endpoint.Simple_routing.hello Page.Simple_routing.hello
  ;;
end

module Counter_vdom = struct
  let home : t =
    straight ~endpoint:Endpoint.Counter_vdom.home Page.Counter_vdom.home
  ;;

  let about : t =
    straight ~endpoint:Endpoint.Counter_vdom.about Page.Counter_vdom.about
  ;;
end
