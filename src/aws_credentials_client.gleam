import gleam/dynamic
import gleam/erlang/atom
import gleam/list
import gleam/option.{type Option}
import gleam/result
import aws_credentials/decoder_simple as decoder
import aws_credentials/ffi
import aws_credentials/app_ffi
import aws_credentials/types.{
  type CredentialError, type Credentials, type RefreshOptions, FetchError,
  NoCredentials, ServiceNotStarted,
}

pub fn start() -> Result(Nil, CredentialError) {
  atom.create("aws_credentials")
  |> app_ffi.safe_ensure_all_started
  |> result.map_error(ServiceNotStarted)
}

pub fn stop() -> Nil {
  ffi.stop()
  Nil
}

pub fn get_credentials() -> Result(Option(Credentials), CredentialError) {
  ffi.get_credentials()
  |> decoder.decode_credentials
  |> result.map_error(FetchError)
}

pub fn force_refresh() -> Result(Option(Credentials), CredentialError) {
  ffi.force_refresh()
  |> decoder.decode_refresh_result
  |> result.map_error(FetchError)
}

pub fn force_refresh_with_options(
  options: RefreshOptions,
) -> Result(Option(Credentials), CredentialError) {
  use erlang_opts <- result.try(prepare_options(options))
  
  ffi.force_refresh_with_options(erlang_opts)
  |> decoder.decode_refresh_result
  |> result.map_error(FetchError)
}

fn prepare_options(options: RefreshOptions) -> Result(List(#(atom.Atom, dynamic.Dynamic)), CredentialError) {
  types.to_erlang_options(options)
  |> list.map(fn(pair) {
    let #(key, value) = pair
    #(atom.create(key), dynamic.string(value))
  })
  |> Ok
}

pub fn has_credentials() -> Bool {
  case get_credentials() {
    Ok(option.Some(_)) -> True
    _ -> False
  }
}

pub fn require_credentials() -> Result(Credentials, CredentialError) {
  use maybe_creds <- result.try(get_credentials())
  
  case maybe_creds {
    option.Some(creds) -> Ok(creds)
    option.None -> Error(NoCredentials)
  }
}