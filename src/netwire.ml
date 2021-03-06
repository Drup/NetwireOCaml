
type ('input, 'output) wire =
  | WArr: ('a -> 'b) -> ('a, 'b) wire
  | WConst: 'b -> (_, 'b) wire
  | WGen: ((unit -> float) -> 'a -> 'b * ('a, 'b) wire) -> ('a, 'b) wire
  | WId: ('a, 'a) wire

let step_wire_int
  : type input out . (input, out) wire -> (unit -> float) -> input -> out * (input, out) wire
  = fun w time_gen input -> match w with
    | WArr f -> (f input, w)
    | WConst mx -> (mx, w)
    | WGen f -> f time_gen input
    | WId -> (input, w)


module Time = struct

  type t = float

  let default_step =
    let init_t = Unix.gettimeofday () in
    fun () -> Unix.gettimeofday () -. init_t

  let time =
    let rec f get_time _ = let t = get_time () in t, w
    and w = WGen f
    in w

end

let step_wire ?(step=Time.default_step) wire input = step_wire_int wire step input

module Util = struct

(*
 We could use:
 type 'o out_wire = { wire : 'a . ('a, 'o) wire }
 It works, but is a bit heavyweight, in practice,
 using a (unit, 'o) wire should be enough.
*)
  let print_wire show wire =
    let rec loop w =
      let output, w = step_wire wire () in
      Printf.printf "\r%s\027[K" (show output) ;
      loop w
    in
    loop wire

end
