type ('request, 'response) t =
  | Straight :
      { middlewares : ('request, 'response) Middleware.t list
      ; endpoint :
          ( [ `Inner ]
            , Method.t
            , 'continuation
            , ('request, 'response) Handler.t )
            Endpoint.wrapped
      ; handler : 'continuation
      }
      -> ('request, 'response) t
  | Straight' :
      { middlewares : ('request, 'response) Middleware.t list
      ; endpoint :
          ( [ `Inner ]
            , Method.t
            , 'continuation
            , 'attachment -> ('request, 'response) Handler.t )
            Endpoint.wrapped
      ; provider :
          ('attachment -> ('request, 'response) Handler.t)
          -> ('request, 'response) Handler.t
      ; handler : 'continuation
      }
      -> ('request, 'response) t
  | Failable :
      { middlewares : ('request, 'response) Middleware.t list
      ; endpoint :
          ( [ `Inner ]
            , Method.t
            , 'continuation
            , ('request, ('result, 'error) result) Handler.t )
            Endpoint.wrapped
      ; handler : 'continuation
      ; ok : 'result -> ('request, 'response) Handler.t
      ; error : 'error -> ('request, 'response) Handler.t
      }
      -> ('request, 'response) t
  | Failable' :
      { middlewares : ('request, 'response) Middleware.t list
      ; endpoint :
          ( [ `Inner ]
            , Method.t
            , 'continuation
            , 'attachment -> ('request, ('result, 'error) result) Handler.t )
            Endpoint.wrapped
      ; provider :
          ('attachment -> ('request, 'response) Handler.t)
          -> ('request, 'response) Handler.t
      ; ok : 'result -> ('request, 'response) Handler.t
      ; error : 'error -> ('request, 'response) Handler.t
      ; handler : 'continuation
      }
      -> ('request, 'response) t

let straight ?(middlewares = []) ~endpoint handler =
  Straight { middlewares; endpoint; handler }
;;

let straight' ?(middlewares = []) ~provider ~endpoint handler =
  Straight' { middlewares; endpoint; provider; handler }
;;

let failable ?(middlewares = []) ~endpoint ~ok ~error handler =
  Failable { middlewares; endpoint; ok; error; handler }
;;

let failable' ?(middlewares = []) ~provider ~endpoint ~ok ~error handler =
  Failable' { middlewares; provider; endpoint; ok; error; handler }
;;

let choose ~services ~given_method ~given_uri fallback request =
  let rec aux = function
    | Straight { endpoint; middlewares; handler } :: continue ->
      (match Endpoint.sscanf endpoint given_method given_uri handler with
       | Some handler -> (Middleware.fold middlewares handler) request
       | None -> aux continue)
    | Straight' { endpoint; middlewares; handler; provider } :: continue ->
      (match Endpoint.sscanf endpoint given_method given_uri handler with
       | Some handler ->
         let inner_handler request = provider handler request in
         (Middleware.fold middlewares inner_handler) request
       | None -> aux continue)
    | Failable { middlewares; endpoint; handler; ok; error } :: continue ->
      (match Endpoint.sscanf endpoint given_method given_uri handler with
       | Some handler ->
         let shell_handler request =
           Lwt.bind (handler request) (function
             | Ok x -> ok x request
             | Error x -> error x request)
         in
         (Middleware.fold middlewares shell_handler) request
       | None -> aux continue)
    | Failable' { middlewares; endpoint; handler; ok; error; provider }
      :: continue ->
      (match Endpoint.sscanf endpoint given_method given_uri handler with
       | Some handler ->
         let shell_handler provider request =
           Lwt.bind (handler provider request) (function
             | Ok x -> ok x request
             | Error x -> error x request)
         in
         let full_handler request = provider shell_handler request in
         (Middleware.fold middlewares full_handler) request
       | None -> aux continue)
    | [] -> fallback request
  in
  aux services
;;
