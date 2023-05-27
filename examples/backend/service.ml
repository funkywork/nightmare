open Nightmare_service.Service

type t = Nightmare_dream.service

let root : t = straight ~endpoint:Endpoint.home Page.home
let about : t = straight ~endpoint:Endpoint.about Page.about
let hello : t = straight ~endpoint:Endpoint.hello Page.hello
