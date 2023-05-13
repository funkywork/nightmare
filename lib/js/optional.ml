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

open Js_of_ocaml

module Make (R : Interfaces.FOLDABLE_OPTION) = struct
  include R

  let halt () = empty
  let iter f x = fold (fun () -> ()) f x

  let equal f left right =
    let left_is_empty () = fold (fun () -> true) (fun _ -> false) right
    and left_is_filled left = fold (fun () -> false) (f left) right in
    fold left_is_empty left_is_filled left
  ;;

  let test x = fold (fun () -> false) (fun _ -> true) x
  let value ~default x = fold (fun () -> default) (fun x -> x) x
  let to_option x = fold (fun () -> None) Stdlib.Option.some x
  let from_option x = Stdlib.Option.fold ~none:empty ~some:fill x
  let to_opt x = fold (fun () -> Js.Opt.empty) Js.Opt.return x
  let from_opt x = Js.Opt.case x halt fill
  let to_optdef x = fold (fun () -> Js.Optdef.empty) Js.Optdef.return x
  let from_optdef x = Js.Optdef.case x halt fill

  let traverse_aux wrap map f =
    fold (fun () -> wrap empty) (fun x -> map fill (f x))
  ;;

  module Functor = Preface.Make.Functor.Via_map (struct
    type nonrec 'a t = 'a t

    let map f x = fold halt (fun x -> fill (f x)) x
  end)

  module Alt =
    Preface.Make.Alt.Over_functor
      (Functor)
      (struct
        type nonrec 'a t = 'a t

        let combine left right = fold (fun () -> right) fill left
      end)

  module Alternative = Preface.Make.Alternative.Via_pure_and_apply (struct
    type nonrec 'a t = 'a t

    let pure = fill
    let neutral = empty
    let combine = Alt.combine

    let apply fs xs =
      let right f x = pure (f x) in
      let left f = fold halt (right f) xs in
      fold halt left fs
    ;;
  end)

  module Applicative =
    Preface.Make.Traversable.Join_with_applicative
      (Alternative)
      (functor
         (A : Preface.Specs.APPLICATIVE)
         ->
         Preface.Make.Traversable.Over_applicative
           (A)
           (struct
             type 'a iter = 'a t
             type 'a t = 'a A.t

             let traverse f x = traverse_aux A.pure A.map f x
           end))

  module Monad_plus = Preface.Make.Monad_plus.Via_bind (struct
    include Alternative

    let return = fill
    let bind f x = fold halt f x
  end)

  module Monad =
    Preface.Make.Traversable.Join_with_monad
      (Monad_plus)
      (functor
         (M : Preface.Specs.MONAD)
         ->
         Preface.Make.Traversable.Over_monad
           (M)
           (struct
             type 'a iter = 'a t
             type 'a t = 'a M.t

             let traverse f x = traverse_aux M.return M.map f x
           end))

  module Selective =
    Preface.Make.Selective.Over_applicative_via_select
      (Applicative)
      (Preface.Make.Selective.Select_from_monad (Monad))

  module Foldable = Preface.Make.Foldable.Via_fold_right (struct
    type nonrec 'a t = 'a t

    let fold_right f x acc = fold (fun () -> acc) (fun x -> f x acc) x
  end)

  module Infix = struct
    let ( <$> ), ( <&> ), ( <$ ), ( $> ) =
      Functor.Infix.(( <$> ), ( <&> ), ( <$ ), ( $> ))
    ;;

    let ( <*> ), ( <**> ), ( *> ), ( <* ) =
      Applicative.Infix.(( <*> ), ( <**> ), ( *> ), ( <* ))
    ;;

    let ( <|> ) = Alternative.Infix.( <|> )

    let ( <*? ), ( <||> ), ( <&&> ) =
      Selective.Infix.(( <*? ), ( <||> ), ( <&&> ))
    ;;

    let ( =|< ), ( >|= ), ( >>= ), ( =<< ), ( >=> ), ( <=< ), ( >> ), ( << ) =
      Monad.Infix.(
        ( =|< ), ( >|= ), ( >>= ), ( =<< ), ( >=> ), ( <=< ), ( >> ), ( << ))
    ;;
  end

  module Syntax = struct
    include Applicative.Syntax

    let ( let* ) = Monad.Syntax.( let* )
  end

  include Syntax
  include Infix
end

module Option = Make (struct
  type 'a t = 'a option

  let empty = None
  let fill x = Some x

  let fold n s = function
    | None -> n ()
    | Some x -> s x
  ;;

  let pp pp' formater = function
    | None -> Format.fprintf formater "None"
    | Some x -> Format.fprintf formater "@[<2>Some@ @[%a@]@]" pp' x
  ;;
end)

module Nullable = Make (struct
  type 'a t = 'a Js.Opt.t

  let empty = Js.Opt.empty
  let fill x = Js.Opt.return x
  let fold n s x = Js.Opt.case x n s

  let pp pp' formater x =
    fold
      (fun () -> Format.fprintf formater "Js.null")
      (fun x -> Format.fprintf formater "@[<2>Js.not_null@ @[%a@]@]" pp' x)
      x
  ;;
end)

module Undefinable = Make (struct
  type 'a t = 'a Js.Optdef.t

  let empty = Js.Optdef.empty
  let fill x = Js.Optdef.return x
  let fold n s x = Js.Optdef.case x n s

  let pp pp' formater x =
    fold
      (fun () -> Format.fprintf formater "Js.undefined")
      (fun x -> Format.fprintf formater "@[<2>Js.not_undefined@ @[%a@]@]" pp' x)
      x
  ;;
end)
