import gleam/dynamic.{type Dynamic}
import gleam/erlang/atom.{type Atom}
import gleam/erlang/process.{type Subject}

pub type CredentialsProcess =
  Subject(Dynamic)

@external(erlang, "aws_credentials", "start_link")
pub fn start_link() -> Dynamic

@external(erlang, "aws_credentials", "stop")
pub fn stop() -> Atom

@external(erlang, "aws_credentials", "get_credentials")
pub fn get_credentials() -> Dynamic

@external(erlang, "aws_credentials", "force_credentials_refresh")
pub fn force_refresh() -> Dynamic

@external(erlang, "aws_credentials", "force_credentials_refresh")
pub fn force_refresh_with_options(options: List(#(Atom, Dynamic))) -> Dynamic

@external(erlang, "erlang", "=:=")
pub fn is_undefined(value: Dynamic, undefined: Atom) -> Bool

pub fn undefined_atom() -> Atom {
  atom.create("undefined")
}

pub fn ok_atom() -> Atom {
  atom.create("ok")
}

pub fn error_atom() -> Atom {
  atom.create("error")
}