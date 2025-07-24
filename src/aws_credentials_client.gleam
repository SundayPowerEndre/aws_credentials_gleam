import gleam/dynamic
import gleam/erlang/atom
import gleam/list
import gleam/option.{type Option}
import aws_credentials/decoder_simple as decoder
import aws_credentials/ffi
import aws_credentials/app_ffi
import aws_credentials/types.{
  type CredentialError, type Credentials, type RefreshOptions, FetchError,
  NoCredentials,
}

pub fn start() -> Result(Nil, CredentialError) {
  let app_atom = atom.create("aws_credentials")
  let _ = app_ffi.ensure_all_started(app_atom)
  
  Ok(Nil)
}

pub fn stop() -> Nil {
  let _ = ffi.stop()
  Nil
}

pub fn get_credentials() -> Result(Option(Credentials), CredentialError) {
  let result = ffi.get_credentials()
  
  case decoder.decode_credentials(result) {
    Ok(creds) -> Ok(creds)
    Error(reason) -> Error(FetchError(reason))
  }
}

pub fn force_refresh() -> Result(Option(Credentials), CredentialError) {
  let result = ffi.force_refresh()
  
  case decoder.decode_refresh_result(result) {
    Ok(option.Some(creds)) -> Ok(option.Some(creds))
    Ok(option.None) -> Ok(option.None)
    Error(reason) -> Error(FetchError(reason))
  }
}

pub fn force_refresh_with_options(
  options: RefreshOptions,
) -> Result(Option(Credentials), CredentialError) {
  let opts = types.get_options(options)
  
  let erlang_opts =
    opts
    |> list.map(fn(pair) {
      let #(key, value) = pair
      #(atom.create(key), dynamic.string(value))
    })
  
  let result = ffi.force_refresh_with_options(erlang_opts)
  
  case decoder.decode_refresh_result(result) {
    Ok(option.Some(creds)) -> Ok(option.Some(creds))
    Ok(option.None) -> Ok(option.None)
    Error(reason) -> Error(FetchError(reason))
  }
}

pub fn has_credentials() -> Bool {
  case get_credentials() {
    Ok(option.Some(_)) -> True
    _ -> False
  }
}

pub fn require_credentials() -> Result(Credentials, CredentialError) {
  case get_credentials() {
    Ok(option.Some(creds)) -> Ok(creds)
    Ok(option.None) -> Error(NoCredentials)
    Error(e) -> Error(e)
  }
}