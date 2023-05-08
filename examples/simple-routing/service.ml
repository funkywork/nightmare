open Nightmare_service.Service

let root = straight ~endpoint:Endpoint.root Page.root
let about = straight ~endpoint:Endpoint.about Page.about
let hello = straight ~endpoint:Endpoint.hello Page.hello
