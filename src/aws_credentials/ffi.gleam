/// FFI bindings to the Erlang aws_credentials library
import gleam/dynamic.{type Dynamic}
import gleam/erlang/atom.{type Atom}
import gleam/erlang/process.{type Subject}

/// Type representing the aws_credentials gen_server process
pub type CredentialsProcess =
  Subject(Dynamic)

/// FFI binding to aws_credentials:start_link/0
@external(erlang, "aws_credentials", "start_link")
pub fn start_link() -> Dynamic

/// FFI binding to aws_credentials:stop/0
@external(erlang, "aws_credentials", "stop")
pub fn stop() -> Atom

/// FFI binding to aws_credentials:get_credentials/0
/// Returns either a map of credentials or 'undefined' atom
@external(erlang, "aws_credentials", "get_credentials")
pub fn get_credentials() -> Dynamic

/// FFI binding to aws_credentials:force_credentials_refresh/0
/// Returns either a map of credentials, 'undefined' atom, or {error, Reason} tuple
@external(erlang, "aws_credentials", "force_credentials_refresh")
pub fn force_refresh() -> Dynamic

/// FFI binding to aws_credentials:force_credentials_refresh/1
/// Takes options as a proplist and returns either credentials, 'undefined', or {error, Reason}
@external(erlang, "aws_credentials", "force_credentials_refresh")
pub fn force_refresh_with_options(options: List(#(Atom, Dynamic))) -> Dynamic

/// FFI binding to check if a value is the 'undefined' atom
@external(erlang, "erlang", "=:=")
pub fn is_undefined(value: Dynamic, undefined: Atom) -> Bool

/// Get the 'undefined' atom
pub fn undefined_atom() -> Atom {
  atom.create("undefined")
}

/// Get the 'ok' atom
pub fn ok_atom() -> Atom {
  atom.create("ok")
}

/// Get the 'error' atom  
pub fn error_atom() -> Atom {
  atom.create("error")
}