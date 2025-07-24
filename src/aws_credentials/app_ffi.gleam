import gleam/dynamic.{type Dynamic}
import gleam/erlang/atom.{type Atom}

@external(erlang, "application", "ensure_all_started")
pub fn ensure_all_started(app: Atom) -> Dynamic