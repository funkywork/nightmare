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
