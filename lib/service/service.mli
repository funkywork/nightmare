(*  MIT License

    Copyright (c) 2023 funkywork

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE. *)

(** A service is the association between an {!type:Endpoint.t} and a handler
    function whose parameters are defined by the endpoint given as an argument.
    A service can be seen as a controller. The separation of the definition of
    endpoints and services makes it possible to use endpoints directly in
    services to generate, for example, the links between different services. *)

(** {1 Types} *)

(** A type that describe a [service]. *)
type ('request, 'response) t

(** {1 Creating services}

    A service is a page, or the result of an API call. It therefore associates
    an endpoint with a specific behaviour. The behaviour is defined, if an
    endpoint matches an HTTP request, by the application of a list of middleware
    and then the execution of a function provisioned by the variables extracted
    from the URL. *)

(** {2 Straight Services}

    {i Straight} services define the simplest form of service. They return
    responses directly (after applying the middleware list). For example, here
    is a very simple service that just say hello world.

    {[
      let hello_endpoint () = Endpoint.(get (~/"hello" / "world"))

      let hello_world_service =
        straight ~endpoint:hello_endpoint (fun _request ->
          Lwt.return "Hello, World!")
      ;;
    ]}

    As our endpoint does not declare any variables, the management function only
    takes the request as an argument. Here is an example that uses variables
    (and and does very complicated arithmetic):

    {[
      let sum_endpoint () = Endpoint.(get (~/"sum" /: int /: int))

      let sum_service =
        straight ~endpoint:sum_endpoint (fun x y _request -> Lwt.return (x + y))
      ;;
    ]}

    It is the type of the [endpoint] that defines the type of the handling
    function. In general, [Endpoints] are defined separately from the service
    because they allow links to be generated between services, so they can
    easily be reused. *)

(** [straight ?middlewares ~endpoint service_handler] declares a {i straight}
    service. *)
val straight
  :  ?middlewares:('request, 'response) Middleware.t list
  -> endpoint:
       ( [ `Inner ]
       , Method.t
       , 'continuation
       , ('request, 'response) Handler.t )
       Endpoint.wrapped
  -> 'continuation
  -> ('request, 'response) t

(** Sometimes it is necessary to provision a service with data before running
    its controller. For example, let's say a service wants a user to be logged
    in to view a page, otherwise it redirects the user to the home page.contents

    First, we need to define a user provider, which is a function that takes
    another handler (which is actually the handler defined by the service
    controller function) and a request. (The function [redirect_to] not really
    exists but it is for the clarity of the example).

    {[
      let provide_user continue request =
        match get_current_user () with
        | None ->
          (* Not logged, we redirect to the login page *)
          redirect_to request login_endpoint
        | Some user ->
          (* If the user is logged, we can continue. *)
          continue user request
      ;;
    ]}

    Now we can define a service that will always be provisioned by a user in his
    controller. Instead of using [straight], we will use [straight'] which
    allows us to be associated with a provisioner.

    {[
      let secret_endpoint () =
        Endpoint.(get (~/"secret" / "page" / "with-password" /: string))
      ;;

      let secret_service =
        straight'
          ~endpoint:secret_endpoint
          ~middlewares:[ is_authenticated ]
          ~provider:provide_user
          (fun password user _request ->
          if String.equal password "secret-password-of-secret-page"
          then Lwt.return ("Hello on the secret page" ^ user.name)
          else Lwt.return "Nothing to see here")
      ;;
    ]}

    Providers are similar to middleware but unlike middleware, instead of just
    modifying the request, they provision the controller of a service with data. *)

(** [straight' ?middlewares ~provider ~endpoint service_handler] declares a
    {i straight} service with provider. *)
val straight'
  :  ?middlewares:('request, 'response) Middleware.t list
  -> provider:
       (('attachment -> ('request, 'response) Handler.t)
        -> ('request, 'response) Handler.t)
  -> endpoint:
       ( [ `Inner ]
       , Method.t
       , 'continuation
       , 'attachment -> ('request, 'response) Handler.t )
       Endpoint.wrapped
  -> 'continuation
  -> ('request, 'response) t

(** {2 Failable services}

    While straight services are very optimistic, when developing a web page it
    is sometimes possible to imagine that the completion of the service
    application may fail. For example if the database returns an error, or if
    data cannot be validated! In contrast to straight services, failable
    services allow the error to be handled at the service definition level.

    Let's improve our [sum] service so that it can perform arbitrary arithmetic
    operations!

    {[
      let binop_endpoint () =
        Endpoint.(post (~/"binop" /: char /: int /: int))
      ;;

      let binop_service () =
        failable
          ~endpoint:binop_endpoint
          ~ok:(fun result request ->
            Lwt.return (string_of_int result)
          ~error:(fun (`Unknown_operator chr) request ->
            Lwt.return ("unknown operator " ^ String.make 1 chr)
          (fun char a b _request ->
            Lwt.return
              (match char with
               | '+' -> Ok (a + b)
               | '-' -> Ok (a - b)
               | '*' -> Ok (a * b)
               | '/' -> Ok Stdlib.(a / b)
               | _ -> Error (`Unknown_operator char)))
      ;;
    ]}

    And that's it! One can easily describe services that have to deal with error
    cases without really caring about them in the controller, and delegate to
    the two visitors [ok] and [error] the handling of both cases, which reduces
    the implicit nesting of the controllers. *)

(** [failable ?middlewares ~endpoint ~ok ~error service_handler] declares a
    {i failable} service. *)
val failable
  :  ?middlewares:('request, 'response) Middleware.t list
  -> endpoint:
       ( [ `Inner ]
       , Method.t
       , 'continuation
       , ('request, ('result, 'error) result) Handler.t )
       Endpoint.wrapped
  -> ok:('result -> ('request, 'response) Handler.t)
  -> error:('error -> ('request, 'response) Handler.t)
  -> 'continuation
  -> ('request, 'response) t

(** In the same way that [straight] services have their [straight'] counterpart
    (which allow the controller of a service to be provisioned with a function,
    similar to middleware), [failable] services have their [failable']
    counterpart which can also be provisioned.

    Let's reuse our [provide_user] provider to illustrate an example using
    [failable']:

    {[
      let secret_failable_endpoint () =
        Endpoint.(
          get (~/"secret" / "failable-page" / "with-password" /: string))
      ;;

      let secret_failable_service =
        failable'
          ~endpoint:secret_failable_endpoint
          ~middlewares:[ is_authenticated ]
          ~provider:provide_user
          ~ok:(fun user _request ->
            Lwt.return @@ "Hello " ^ user.name ^ " in the secret page")
          ~error:(fun `Invalid_password _request ->
            Lwt.return
              "Bad password! try `secret-password-of-another-secret-page`")
          (fun password user _request ->
            if String.equal password "secret-password-of-another-secret-page"
            then Lwt.return @@ Ok user
            else Lwt.return @@ Error `Invalid_password)
      ;;
    ]}

    With this pattern, we can easily separate the different steps of a service
    that needs to be provisioned and may fail into four distinct steps:

    - Middleware Application
    - Compute provisionned data (or acting on the request)
    - Compute the body of the service via the controller
    - Deal with the success case or the failure case. *)

(** [failable ?middlewares ~endpoint ~ok ~error service_handler] declares a
    {i failable} service with provider. *)
val failable'
  :  ?middlewares:('request, 'response) Middleware.t list
  -> provider:
       (('attachment -> ('request, 'response) Handler.t)
        -> ('request, 'response) Handler.t)
  -> endpoint:
       ( [ `Inner ]
       , Method.t
       , 'continuation
       , 'attachment -> ('request, ('result, 'error) result) Handler.t )
       Endpoint.wrapped
  -> ok:('result -> ('request, 'response) Handler.t)
  -> error:('error -> ('request, 'response) Handler.t)
  -> 'continuation
  -> ('request, 'response) t

(** {1 Routing services}

    As variables of heterogeneous types are packaged existentially in the type
    of a service, it is possible to treat them uniformly in a list. It is
    therefore possible to choose, from a list, which one to execute according to
    a given URL and a given method. As the list is traversed in the correct
    order, the order in the list makes sense. *)

(** [choose ~services ~given_method ~given_url] return a {!type:Middleware.t}
    that find the right service or relay on a fallback.*)
val choose
  :  services:('request, 'response) t list
  -> given_method:Method.t
  -> given_uri:string
  -> ('request, 'response) Middleware.t
