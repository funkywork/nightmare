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

(** A {{!type:t} path} is a fragment of the URL. For example, in the following
    URL: ["https://foo.bar/a/b/c"], [a/b/c] is the {{!type:t} path}. In the
    construction of links or controllers between different services, we
    generally use path which can introduce constant fragments, or
    {{!type:variable} variables}.

    For example, consider this URL fragment:
    ["user/123e4567-e89b-12d3-a456-426614174000"], we can assume that [user] is
    constant while the path suffix is a UUID, which can vary depending on the
    profile we want to display.

    This separation between constant fragments and {{!type:variable} variables}
    allows a bidirectional use of {{!type:t} path} (being able to produce links,
    or being able to interpret links, i.e. for a given path, providing a
    function that extracts the {{!type:variable} variables} parts).*)

(** {1 Variables}

    Combinators to describe {{!type:variable} variables} in a {{!type:t} path}. *)

(** A [variable] describes how to serialize and deserialize an arbitrary value
    to and from a string. It is therefore a function pair:
    [from_string : string -> 'a option] and [to_string: 'a -> string]. *)
type 'a variable

(** [variable ~from_string ~to_string name] constructs a value of type
    ['a variable]. In order to be able to construct only valid URLs, it is
    suggested to avoid constructing variables for type aliases (e.g. to describe
    a UUID) and to use abstract types to force their validated creation.

    The [name] parameter is used for giving a pretty-printer for not-handled
    path. (See {!val:pp}) *)
val variable
  :  from_string:(string -> 'a option)
  -> to_string:('a -> string)
  -> string
  -> 'a variable

(** [variable' (module Fragment)] uses a module (of type
    {!module-type:Signatures.PATH_FRAGMENT}) instead of a pair of function and a
    name. *)
val variable'
  :  (module Signatures.PATH_FRAGMENT with type t = 'a)
  -> 'a variable

(** {2 Pre-defined variable descriptor}

    Set of predefined variable descriptors for common and usual types. *)

module Preset : sig
  (** [string] describes a variable of type [string]. *)
  val string : string variable

  (** [int] describes a variable of type [int]. *)
  val int : int variable

  (** [float] describes a variable of type [float]. *)
  val float : float variable

  (** [bool] describes a variable of type [bool]. *)
  val bool : bool variable

  (** [char] describes a variable of type [char]. *)
  val char : char variable
end

include module type of Preset (** @inline *)

(** {1 Path}

    A path is described by a type parameterised by two other types. The first,
    ['continuation] defines the type of continuation generated by the path, and
    ['witness] defines the return type of the continuation (which varies
    depending on how one decides to use the path). So [`handler_continuation]
    always has ['witness] as the last type.

    Here are some examples of continuations generated for given fragments. (It
    is assumed that the expressions described by [":type"] describe a fragment
    that is a variable of type [type]:

    - ["/"] will have the type ['witness]
    - ["/foo/bar"] will have the type ['witness] because the [path] does not
      introduce a variable
    - ["foo/:string/:int/bar"] will have the type [string -> int -> 'witness].

    It should therefore be borne in mind that the first type parameter
    ['continuation] of a path describes a continuation whose normal form will
    always, invariably be the second type parameter (['witness]) and the latter
    varies according to usage. If for example the [path] is used to generate a
    string, it will be of type [string] (and the continuation will be of type
    ['a -> string].*)

type ('continuation, 'witness) t

(** A [wrapped] path is wrapped in a [unit -> t] function to avoid the value
    restriction. *)

type ('continuation, 'witness) wrapped = unit -> ('continuation, 'witness) t

(** {2 Composing path} *)

(** [root] returns the root of a {{!type:t} path}. Every path starts with a
    root. *)
val root : ('witness, 'witness) t

(** [add_constant str path] returns a new {{!type:t} path} with a constant
    fragment. *)
val add_constant
  :  string
  -> ('continuation, 'witness) t
  -> ('continuation, 'witness) t

(** [add_variable variable path] returns a new {{!type:t} path} with a variable
    fragment. *)
val add_variable
  :  'new_variable variable
  -> ('continuation, 'new_variable -> 'witness) t
  -> ('continuation, 'witness) t

(** {3 Example}

    For example, let's imagine this URL fragment, which can retrieve the first
    [N] messages posted by a user in a certain category:
    [get_messages/:int/by_user/:string/in_category/:string] (Yes, it's not a
    very RESTful fragment). This is how we could describe the corresponding
    path:

    {[
      let a_path =
        root
        |> add_constant "get_messages"
        |> add_variable int
        |> add_constant "by_user"
        |> add_variable string
        |> add_constant "in_category"
        |> add_variable string
      ;;
    ]} *)

(** {2 Infix operators} *)

module Infix : sig
  (** As the non-infix way of describing paths is rather verbose, here is a
      collection of infix operators to describe a path in a rather natural way. *)

  (** [~/str] is [root |> add_constant str]. *)
  val ( ~/ ) : string -> ('witness, 'witness) t

  (** [~/:var] is [root |> add_variable var]. *)
  val ( ~/: )
    :  'new_variable variable
    -> ('new_variable -> 'witness, 'witness) t

  (** [path / str] is [path |> add_constant str]. A (flipped) infix version of
      {!val:add_constant}. *)
  val ( / )
    :  ('continuation, 'witness) t
    -> string
    -> ('continuation, 'witness) t

  (** [path /: var] is [path |> add_variable var]. A (flipped) infix version of
      {!val:add_variable}. *)
  val ( /: )
    :  ('continuation, 'new_variable -> 'witness) t
    -> 'new_variable variable
    -> ('continuation, 'witness) t
end

include module type of Infix (** @inline *)

(** {3 Example}

    Let's go back to our previous example
    ([get_messages/:int/by_user/:string/in_category/:string]).With infix
    operators, writing a path that captures these fragments is much shorter:

    {[
      let a_path =
        ~/"get_message" /: int / "by_user" /: string / "in_category" /: string
      ;;
    ]} *)

(** {2 Pretty-printing and scanning}

    Even if these functions are globally "low-level" (and intended to be used in
    other constructs), it is possible to print a path, like the [Format.sprintf]
    function, and to scan a string by agreeing on the pattern described by a
    path (like the [Scanf.sscanf]). *)

(** {3 Pretty-printing} *)

(** [sprintf path] will return a function that need all defined variables into
    the path and will produce a corresponding string. *)
val sprintf : ('continuation, string) t -> 'continuation

(** [sprintf_with path handler] will return a function that need all defined
    variables into the path and will produce a corresponding string and apply
    [handler] to that produced string.

    This function is useful if you want to apply a finalizer to the output of a
    path that has not yet been completely calculated. For example,
    {!val:sprintf} is a specialised version of [sprintf_with]:
    [let sprintf path = sprintf_with path (fun x -> x)]. *)
val sprintf_with
  :  ('continuation, 'witness) t
  -> (string -> 'witness)
  -> 'continuation

(** A regular pretty-printer for a [path] that print variables using their
    type-names. For example : [~/ "foo" /: int / "bar" /: string] will print
    ["/foo/:int/bar/:string"]. *)
val pp : Format.formatter -> ('continuation, 'witness) t -> unit

(** {4 Example}

    When there are no variables, {!val:sprintf} is used quite simply. For
    example: [sprintf (~/"foo"/"bar"/"baz")] will produce the string
    ["/foo/bar/baz"].

    On the other hand, when the [path] introduces variables, {!val:sprintf} will
    return a function expecting parameters with types corresponding to those
    defined in the path variables. So to transform our previous example
    ([get_messages/:int/by_user/:string/in_category/:string]) into a string, we
    will have to give it, in order, an integer, and two strings:

    {[
      let path =
        ~/"get_message" /: int / "by_user" /: string / "in_category" /: string
      in
      sprintf path 42 "grm" "global"
    ]}

    In this example, the result will be:
    ["/get_message/42/by_user/grm/in_category/global"]. *)

(** {3 Scanning and interpreting} *)

(** [sscanf path uri handler] will try to interpret a [string] according to a
    [path] and performing [handler] which is a function that takes one argument
    per variables defined in the [path]. If the given [uri] match, the [handler]
    will be performed and the result will be wrapped into [Some], otherwise, the
    result will be [None]. *)
val sscanf
  :  ('continuation, 'witness) t
  -> string
  -> 'continuation
  -> 'witness option

(** {4 Example}

    For example, let's consider this function:

    {[
      sscanf
        (~/"test" / "of" /: int /: string /: bool)
        uri_str
        (fun x y z ->
          let bool_message = if z then "[x]" else "[x]" in
          Format.asprintf "%s - %s (%d)" bool_message y x)
    ]}

    We see that it can only accept URIs that are suffixed with ["/test/of/"] and
    then take an integer, a string and a boolean. So :

    - with [let uri_str = "/"] the function will return [None]
    - with [let uri_str = "/test/of/10/foo/true"] the function will return
      [Some "[v] - foo (10)"]
    - with [let uri_str = "/test/of/NaN/foo/true"] the function will return
      [None] because [NaN] is not a valid integer.

    As with {!val:sprintf}, {!val:sscanf} is a relatively "low-level" function,
    which, at a higher level, is mainly used for routing. *)
