import gleam/dynamic.{type Dynamic}
import gleam/erlang/atom.{type Atom}
import gleam/string

@external(erlang, "application", "ensure_all_started")
pub fn ensure_all_started(app: Atom) -> Dynamic

pub fn safe_ensure_all_started(app: Atom) -> Result(Nil, String) {
  let result = ensure_all_started(app)
  
  case decode_start_result(result) {
    Ok(_) -> Ok(Nil)
    Error(reason) -> Error(reason)
  }
}

@external(erlang, "erlang", "is_tuple")
fn is_tuple(value: Dynamic) -> Bool

@external(erlang, "gleam_stdlib", "identity")
fn unsafe_coerce_tuple2(value: Dynamic) -> #(Dynamic, Dynamic)

@external(erlang, "gleam_stdlib", "identity")
fn unsafe_coerce_atom(value: Dynamic) -> Atom

fn decode_start_result(result: Dynamic) -> Result(List(Atom), String) {
  case is_tuple(result) {
    True -> {
      let #(tag_dyn, value_dyn) = unsafe_coerce_tuple2(result)
      case is_atom_string(tag_dyn, "ok") {
        True -> Ok([])
        False -> {
          case is_atom_string(tag_dyn, "error") {
            True -> Error("Failed to start application: " <> string.inspect(value_dyn))
            False -> Error("Unexpected result: " <> string.inspect(result))
          }
        }
      }
    }
    False -> Error("Unexpected non-tuple result: " <> string.inspect(result))
  }
}

@external(erlang, "erlang", "is_atom")
fn is_atom(value: Dynamic) -> Bool

fn is_atom_string(value: Dynamic, expected: String) -> Bool {
  case is_atom(value) {
    True -> {
      let a = unsafe_coerce_atom(value)
      atom.to_string(a) == expected
    }
    False -> False
  }
}