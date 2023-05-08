open Nightmare_service.Endpoint

let root () = get root
let about () = get ~/"about"
let hello () = get (~/"hello" /: string)
