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

(** A dead simple binding of the debugging console. The correspondence of the
    functions can be found on the MND documentation:
    {{:https://developer.mozilla.org/en-US/docs/Web/API/Console} WebAPI/Console}.

    The goal of this module is mostly for debugging. *)

open Aliases
open Js_of_ocaml

(** {1 Basis functionality}

    Straightforward binding of console utilities. *)

(** [Console.clear ()] clears the console if the console allows it. *)
val clear : unit -> unit

(** [Console.log x] logs an aribtrary value [x] in the console. *)
val log : 'a -> unit

(** [Console.debug x] outputs an arbitrary value [x] to the console with the log
    level [debug]. *)
val debug : 'a -> unit

(** [Console.info x] informative logging of an arbitrary value [x]. *)
val info : 'a -> unit

(** [Console.warning x] outputs a warning message of an arbitrary value [x]. *)
val warning : 'a -> unit

(** [Console.error x] outputs an error message of an arbitrary value [x]. *)
val error : 'a -> unit

(** [Console.dir js_value] displays an interactive list of the properties of the
    specified JavaScript object ([js_value]). The output is presented as a
    hierarchical listing with disclosure triangles that let you see the contents
    of child objects.
    {b This is why you can't pass an regular OCaml value but you have to give a
    JavaScript one}. *)
val dir : 'a js -> unit

(** [Console.dir_xml node] displays an interactive tree of the descendant
    elements of the specified XML/HTML element ([node]). *)
val dir_xml : Dom.node js -> unit

(** [Console.trace ()] outputs a stack trace to the Web console. *)
val trace : unit -> unit

(** [Console.assert' ?message ?payload assertion] writes an error message to the
    console if the assertion is false. If the assertion is true, nothing
    happens. *)
val assert' : ?message:string -> ?payload:'a -> bool -> unit

(** [Console.table ?columns js_value] displays tabular data as a table. *)
val table : ?columns:string list -> 'a js -> unit

(** [Console.string handler str] allows you to easily display OCaml strings. It
    is used with another function. For example :
    [Console.(string warning "Attention")].

    Which will display [" Attention"] in a [warning]. *)
val string : (Js.js_string js -> unit) -> string -> unit

(** {1 Timer} *)

module Timer : sig
  (** Allows you to start (and stop) and monitor timers from the console. *)

  (** Returns the default label, used when no specific label is given to the
      following functions. *)
  val default_label : string

  (** [Console.Timer.start ?label ()] starts a [timer] with a given [label] (if
      the [label] is not given, it will use ["default"] as a label). *)
  val start : ?label:string -> unit -> unit

  (** [Console.Timer.stop ?label ()] stops a [timer] of a given [label] (if the
      [label] is not given, it will use ["default"] as a label). *)
  val stop : ?label:string -> unit -> unit

  (** [Console.Timer.log ?label ?payload ()] logs the current value of a timer.
      with a given [label] (if the [label] is not given, it will use ["default"]
      as a label). A [payload] can be also dumped. *)
  val log : ?label:string -> ?payload:'a -> unit -> unit
end

(** {1 Counter} *)

module Counter : sig
  (** Allows you to tick (and log) and reset counters from the console. *)

  (** Returns the default label, used when no specific label is given to the
      following functions. *)
  val default_label : string

  (** [Console.Counter.tick ?label ()] logs the number of times that this
      particular call to [tick] has been called for a given [label]. (if the
      [label] is not given, it will use ["default"] as a label) *)
  val tick : ?label:string -> unit -> unit

  (** [Console.Counter.reset ?label ()] resets counter of a given [label] (if
      the [label] is not given, it will use ["default"] as a label). *)
  val reset : ?label:string -> unit -> unit
end

(** {1 Indent}

    This is usually referred to as [groups]. But it allows you to build
    indentation levels in console logging. *)

module Indent : sig
  (** Add or remove indentation levels in the console. *)

  (** [Console.Indent.increase ?collapsed ?label ()] creates an indentation
      level (which may or may not be open via the [collapsed] parameter and may
      or may not have a textual [label]). *)
  val increase : ?collapsed:bool -> ?label:string -> unit -> unit

  (** [Console.Ident.decrease ()] reduce the current level of indentation. *)
  val decrease : unit -> unit
end
