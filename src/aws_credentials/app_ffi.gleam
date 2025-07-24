/// FFI bindings for OTP application management
import gleam/dynamic.{type Dynamic}
import gleam/erlang/atom.{type Atom}

/// Start an OTP application and all its dependencies
@external(erlang, "application", "ensure_all_started")
pub fn ensure_all_started(app: Atom) -> Dynamic