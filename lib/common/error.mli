(*  MIT License

    Copyright (c) 2022 funkywork

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

(** Description of errors. As the framework is intended to be extensible, error
    reporting is done by defining an extensible variant (which can be extended
    into other modules) and registering a handler, to add error handling after
    the fact. All errors are stored in a mutable space hidden from the user (for
    easy access).

    The API is strongly inspired by {{:https://tezos.com} Tezos}' error
    handling.

    {1 How to declare an error}

    {2 Deal with errors in OCaml}

    Working with extensible errors is relatively complicated. In geneŕal, OCaml,
    there are two approaches:

    - Dealing with exceptions
    - Dealing with [('a, 'b) Result.t]

    The problem with exceptions is that they are not caught by the type system,
    and the user must potentially describe handling for exceptions other than
    those described.

    Using the [result] type allows errors to be propagated which are reflected
    in the type system. Coupled with polymorphic variants, it is possible to
    capture them dynamically. However, in user terms, this implies knowing the
    different handlers for each of the propagatable errors.

    Although this is probably not the ideal approach, [Nightmare] proposes to
    use an open variant (a bit like an exception) but {i impose} a registration
    process. This allows errors to be declared individually, storing them in a
    mutable table, and providing the necessary functions to automate the
    generation of their equality function and pretty-printer. Although this
    forces the use of mutability and makes the process of dealing with an error
    potentially less efficient (you have to "look up the error in the table"),
    it is assumed that the error table will remain small enough not to cause any
    significant performance loss. This approach allows errors to be reported
    independently of each other.

    {2 Example}

    Let's imagine an error that characterizes an integer not included in a given
    bound, let's start by describing its variant. First, we need to add an
    extension to the known errors:

    {[
      type errors = Nightmare_common.Error.t = ..
    ]}

    Then we can add the constructor characterising our error:

    {[
      type errors +=
        | Integer_not_included_in_the_range of
            { min_bound : int
            ; max_bound : int
            ; given_value : int
            }
    ]}

    Now we need to register the error using the {!val:register} function.

    {[
      let () =
        register
          ~id:"my_domain.integer_not_included_in_the_range"
          ~title:"Integer not included in the range"
          ~description:"An integer should be included in the given range"
          ~pp:(fun ppf (min_bound, max_bound, given_value) ->
            Format.fprintf
              ppf
              "Error, %d should be >= %d and <= %d"
              given_value
              min_bound
              max_bound)
          (function
           | Integer_not_included_in_the_range
               { min_bound; max_bound; given_value } ->
             Some (min_bound, max_bound, given_value)
           | _ -> None)
          (fun (min_bound, max_bound, given_value) ->
            Integer_not_included_in_the_range
              { min_bound; max_bound; given_value })
          (fun (min_a, max_a, given_a) (min_b, max_b, given_b) ->
            Int.equal min_a min_b
            && Int.equal max_a max_b
            && Int.equal given_a given_b)
      ;;
    ]}

    Ça peut sembler un peu verbeux mais ça permet d'introduire les erreurs une
    par une, peu importe le module et d'en définir des pretty-printers et des
    fonctions d'égalités en ne se souciant que du minimum. *)

(** {1 Type}

    Extensible variable describing the set of errors. *)

type t = ..

(** Type for a registered error. *)
type registered =
  { id : string
  ; title : string
  ; description : string
  ; pp : Format.formatter -> t -> unit
  ; equal : t -> t -> bool
  }

(** {2 Predefined errors}

    A list of predefined errors, necessary for the proper functioning of the
    framework. *)

(** When an error is unknown. For example, when trying to retrieve an unrecorded
    error. ([Unknown] can act as a neutral element for error handling.) *)
type t += Unknown

(** An arbitrary error attached to a message. *)
type t += With_message of { message : string }

(** {1 API} *)

(** {2 Error registration}

    As mentioned in the tutorial, an error must be registered. *)

(** [register ~id ~title ~description ~pp from_error to_error equal] Will
    register a new error.

    - [id] is a short identifier (in general, nightmare error identifiers are
      prefixed with ["nightmare."])
    - [title] a title describing the error
    - [description] a description of the context in which the error is
      propagated (or what it means)
    - [pp] is a pretty-printer that acts on the form extracted from the
      parameters of the error constructor
    - [from_error] is a function that, if the error matches the one recorded,
      extracts its parameters packed in an option. If the error does not match,
      it returns [None]. (It is this function that allows generic error
      handling).
    - [to_error] is the dual of [from_error], it takes the parameter (of the
      same form as that extracted and wrapped by [from_error]) and builds the
      corresponding error
    - [equal] is an equality function that acts only on the constructor
      parameter (and which will be used to produce an equality function that
      will act on an error). *)
val register
  :  id:string
  -> title:string
  -> description:string
  -> pp:(Format.formatter -> 'a -> unit)
  -> (t -> 'a option)
  -> ('a -> t)
  -> ('a -> 'a -> bool)
  -> unit

(** {2 Utils} *)

(** [handle error callback] will perform the given [callback] on the error.
    {b this function relay on the global table of error}

    {b Example of usage:}

    Let's write a tiny [handler] that displays a success or an error on the
    standard output:

    {[
      match my_failable_result with
      | Ok result -> print_endline ("succeed with" ^ result)
      | Error err ->
        Nightmare_common.Error.handle err (fun { pp; _ } err ->
          let message = Format.asprintf "Fail with: %a " pp err in
          print_endline message)
    ]} *)
val handle : t -> (registered -> t -> 'a) -> 'a

(** [equal err_a err_b] return [true] if [err_a] is equal to [err_b], [false]
    otherwise. {b this function relay on the global table of error}. *)
val equal : t -> t -> bool

(** A pretty-printer for [t].
    {b this function relay on the global table of error}. *)
val pp : Format.formatter -> t -> unit
