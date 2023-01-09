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

(** An {{!type:t} endpoint} is the conjunction of three components: a [scope], a
    {{!type:Method.t} method} and a {{!type:Path.t} path}. The [scope] describes
    whether the endpoint points to a service (so it {b can be interpreted}) and
    is referred to as an [Inner endpoint] or whether the endpoint points to an
    external resource (which {b cannot be interpreted}) and is referred to as an
    [Outer endpoint].

    Endpoints are defined separately, uncoupled from their controllers so that
    they can be used between different controllers to build links between them
    without suffering from complicated mutual recursions. *)

(** {1 types}

    An endpoint is set up with 4 types:

    - ['scope] which can be [ `Inner] or [`Outer], describing whether the
      endpoint can be interpreted or not
    - ['method] which is always of type {!type:Method.t}
    - ['continuation] and ['witness] which are the two parameters of the
      {!type:Path.t} used to describe the path *)

(** The type describing an [endpoint]. *)
type ('scope, 'method_, 'continuation, 'witness) t

(** A [wrapped] endpoint is wrapped in a [unit -> t] function to avoid the value
    restriction. *)

type ('scope, 'method_, 'continuation, 'witness) wrapped =
  unit -> ('scope, 'method_, 'continuation, 'witness) t

(** {1 Constructing inner endpoint}

    The construction of an [inner endpoint] is simply the association between a
    {!type:Method.t} and {!type:Path.t}. *)

(** [get path] builds an [inner endpoint] for the [GET] method attached to the
    given [path]. *)
val get
  :  ('continuation, 'witness) Path.t
  -> ([> `Inner ], [> `GET ], 'continuation, 'witness) t

(** [post path] builds an [inner endpoint] for the [POST] method attached to the
    given [path]. *)
val post
  :  ('continuation, 'witness) Path.t
  -> ([> `Inner ], [> `POST ], 'continuation, 'witness) t

(** [put path] builds an [inner endpoint] for the [PUT] method attached to the
    given [path]. *)
val put
  :  ('continuation, 'witness) Path.t
  -> ([> `Inner ], [> `PUT ], 'continuation, 'witness) t

(** [delete path] builds an [inner endpoint] for the [DELETE] method attached to
    the given [path]. *)
val delete
  :  ('continuation, 'witness) Path.t
  -> ([> `Inner ], [> `DELETE ], 'continuation, 'witness) t

(** [head path] builds an [inner endpoint] for the [HEAD] method attached to the
    given [path]. *)
val head
  :  ('continuation, 'witness) Path.t
  -> ([> `Inner ], [> `HEAD ], 'continuation, 'witness) t

(** [connect path] builds an [inner endpoint] for the [CONNECT] method attached
    to the given [path]. *)
val connect
  :  ('continuation, 'witness) Path.t
  -> ([> `Inner ], [> `CONNECT ], 'continuation, 'witness) t

(** [options path] builds an [inner endpoint] for the [OPTIONS] method attached
    to the given [path]. *)
val options
  :  ('continuation, 'witness) Path.t
  -> ([> `Inner ], [> `OPTIONS ], 'continuation, 'witness) t

(** [trace path] builds an [inner endpoint] for the [TRACE] method attached to
    the given [path]. *)
val trace
  :  ('continuation, 'witness) Path.t
  -> ([> `Inner ], [> `TRACE ], 'continuation, 'witness) t

(** [patch path] builds an [inner endpoint] for the [PATCH] method attached to
    the given [path]. *)
val patch
  :  ('continuation, 'witness) Path.t
  -> ([> `Inner ], [> `PATCH ], 'continuation, 'witness) t

(** {2 Examples}

    The definition of an endpoint is simply to describe a function that takes
    [unit] and returns a {!type:t}. (Since an endpoint can be used in multiple
    place and the second parameter, ['witness] is fixed by the usage, for
    example, the ['witness] can vary if you want to generate a link (it will
    return a [string]) or interpret a [path] as a route which will return a
    [http response]. So in order to avoid an early type-fixing, we wrap an
    endpoint into a function from [unit] to {!type:t}.)

    {[
      let my_first_endpoint () = get (~/"hello" / "world")
      let an_other_endpoint () = post (~/"hello" /: string)
    ]} *)

(** {1 Constructing outer endpoint}

    An [outer endpoint] is just a prefix, for example ["https://mon-site.com"]
    associated with a method and a path. For simplicity, you can lift an
    [inner endpoint] to an [outer endpoint] using the {!val:outer} function. *)

(** [outer inner_f prefix path] build a [outer endpoint]. The [inner_f] is one
    of the function {!val:get}, {!val:post}, {!val:put}, {!val:delete},
    {!val:patch}, {!val:head}, {!val:connect}, {!val:options}, {!val:trace}. *)
val outer
  :  (('continuation, 'witness) Path.t
      -> ([ `Inner ], 'method_, 'continuation, 'witness) t)
  -> string
  -> ('continuation, 'witness) Path.t
  -> ([> `Outer ], 'method_, 'continuation, 'witness) t

(** {2 Examples}

    Although the signature may be intimidating, building an [outer endpoint] is
    really simple! Let's say I wanted to go to a github profile, I could simply
    describe its endpoint like this:

    {[
      let github_profile () = outer get "https://github.com" Path.(~/:string)
    ]} *)

(** {1 Link generation and pretty-printing}

    As seen in the {!module:Path}, the way a path is constructed allows it to be
    used bi-directionally. Overall, the generation of a link or target does not
    do much more, except that it prohibits certain generations. For example,
    since HTML only allows [GET] hyperlinks (whose tag attribute is [href]), it
    is impossible (it's typechecked) to create a URL for a [<a>] using the
    functions related to [href] generation. *)

(** [href ?anchor ?parameters endpoint] will return a function that need all
    defined variables into the path burried into the endpoint and will produce a
    corresponding string adding [anchor] and [get parameters] (if they are
    defined).
    {b this function works only for [GET] endpoints ([Inner] or [Outer])}
    because HTML links only admit [GET] request.*)
val href
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ('scope_, [< Method.for_link ], 'continuation, string) wrapped
  -> 'continuation

(** [href_with ?anchor ?parameters endpoint handler] will return a function that
    need all defined variables into the path and will produce a corresponding
    string adding [anchor] and [get parameters] (if they are defined) and apply
    [handler] tot that produced string.

    This function is, like {!val:Path.sprintf_with} useful if you want to apply
    a finalizer to the output of a path that has not yet been completely
    calculated. For example, {!val:href} is a specialized version of
    [href_with]:

    {[
      let href ?anchor ?parameters endpoint =
        href_with ?anchor ?parameters endpoint (fun x -> x)
      ;;
    ]}

    {b As with {!val:href}, the function can only be used for [GET] endpoints
      ([Inner] or [Outer]).} *)
val href_with
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ('scope_, [< Method.for_link ], 'continuation, 'witness) wrapped
  -> (string -> 'witness)
  -> 'continuation

(** [form_method endpoint] will returns the method of a form.
    {b Since HTML form can just handle [GET] and [POST] form, the function can
      just take those as an argument}. *)
val form_method
  :  ([ `Inner | `Outer ], Method.for_form_action, _, _) wrapped
  -> [> Method.for_form_action ]

(** [form_action ?anchor ?parameters endpoint] will return a function that need
    all defined variables into the path burried into the endpoint and will
    produce a corresponding string adding [anchor] and [get parameters] (if they
    are defined).
    {b this function works only for [GET] and [POST] endpoints ([Inner] or
      [Outer])} because HTML form only admit [GET] or [POST] request.*)
val form_action
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ('scope_, [< Method.for_form_action ], 'continuation, string) wrapped
  -> 'continuation

(** [form_action_with ?anchor ?parameters endpoint handler] will return a
    function that need all defined variables into the path and will produce a
    corresponding string adding [anchor] and [get parameters] (if they are
    defined) and apply [handler] tot that produced string.

    This function is, like {!val:Path.sprintf_with} useful if you want to apply
    a finalizer to the output of a path that has not yet been completely
    calculated. For example, {!val:form_action} is a specialized version of
    [form_action_with] *)
val form_action_with
  :  ?anchor:string
  -> ?parameters:(string * string) list
  -> ('scope_, [< Method.for_form_action ], 'continuation, 'witness) wrapped
  -> (string -> 'witness)
  -> 'continuation

(** {1 Scanning and interpreting}

    After being able to generate links (for [a] tags or as a form action) it is
    also possible to interpret [endpoint]. As with the {!val:Path.sscanf}
    function, {!val:sscanf} allows you to interpret an [endpoint] by ensuring
    that the method given as an argument matches the method attached to the
    [endpoint].

    {b Interpretation is only possible for [Inner endpoints], logically, what
      sense does it make to try to interpret a route that is not served by the
      application} *)

(** [sscanf endpooint given_method given_uri handler] will perform [handler]
    (provisioned with the extracted variables) if the given method matches the
    one buried in the endpoint and return its result wrapped in a [Some], if the
    endpoint is not a candidate, it will return [None].*)
val sscanf
  :  ([ `Inner ], Method.t, 'continuation, 'witness) wrapped
  -> Method.t
  -> string
  -> 'continuation
  -> 'witness option

(** {1 Infix operators}

    The [Endpoint] module re-exports the operators from {!module:Path.Infix} so
    that the [Endpoint] opening is sufficient to build the [Endpoint] and the
    [Path] without having to couple the local openings. *)

module Infix = Path.Infix

include module type of Path.Infix (** @closed*)
