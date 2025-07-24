/// Type-safe AWS credentials management for Gleam
/// 
/// This library provides a Gleam wrapper around the battle-tested 
/// `aws_credentials` Erlang library, offering type-safe credential
/// management with automatic refresh.
///
/// ## Example
/// 
/// ```gleam
/// import aws_credentials
/// import gleam/io
/// import gleam/option
/// 
/// pub fn main() {
///   // Start the credentials service
///   let assert Ok(_) = aws_credentials.start()
///   
///   // Get credentials
///   case aws_credentials.get_credentials() {
///     Ok(option.Some(creds)) -> {
///       io.println("Access Key: " <> creds.access_key_id)
///     }
///     Ok(option.None) -> io.println("No credentials available")
///     Error(e) -> io.println("Error: " <> string.inspect(e))
///   }
/// }
/// ```
import gleam/dynamic.{type Dynamic}
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

/// Start the AWS credentials service
/// 
/// This starts the underlying gen_server that manages credential fetching
/// and automatic refresh. The service will automatically fetch credentials
/// from the configured providers (environment variables, files, ECS, EC2, etc.)
pub fn start() -> Result(Nil, CredentialError) {
  // First ensure the aws_credentials application is started
  let app_atom = atom.create("aws_credentials")
  let _ = app_ffi.ensure_all_started(app_atom)
  
  // Now we can use the service (it's already started by the application)
  Ok(Nil)
}

/// Stop the AWS credentials service
/// 
/// This cleanly shuts down the credentials service.
pub fn stop() -> Nil {
  let _ = ffi.stop()
  Nil
}

/// Get the current AWS credentials
/// 
/// Returns the cached credentials if available. The credentials are
/// automatically refreshed in the background when they expire.
/// 
/// Returns:
/// - `Ok(Some(credentials))` if credentials are available
/// - `Ok(None)` if no credentials could be found
/// - `Error(ServiceNotStarted)` if the service is not running
pub fn get_credentials() -> Result(Option(Credentials), CredentialError) {
  let result = ffi.get_credentials()
  
  case decoder.decode_credentials(result) {
    Ok(creds) -> Ok(creds)
    Error(reason) -> Error(FetchError(reason))
  }
}

/// Force a refresh of the credentials
/// 
/// This triggers an immediate fetch of new credentials from the 
/// configured providers, bypassing any cached values.
/// 
/// Returns:
/// - `Ok(Some(credentials))` if new credentials were fetched
/// - `Ok(None)` if no credentials could be found
/// - `Error(reason)` if an error occurred during fetch
pub fn force_refresh() -> Result(Option(Credentials), CredentialError) {
  let result = ffi.force_refresh()
  
  case decoder.decode_refresh_result(result) {
    Ok(option.Some(creds)) -> Ok(option.Some(creds))
    Ok(option.None) -> Ok(option.None)
    Error(reason) -> Error(FetchError(reason))
  }
}

/// Force a refresh of the credentials with custom options
/// 
/// This allows passing provider-specific options to customize the
/// credential fetching behavior.
pub fn force_refresh_with_options(
  options: RefreshOptions,
) -> Result(Option(Credentials), CredentialError) {
  let opts = types.get_options(options)
  
  // Convert string keys to atoms for Erlang
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

/// Check if credentials are available
/// 
/// This is a convenience function that returns True if valid credentials
/// can be fetched, False otherwise.
pub fn has_credentials() -> Bool {
  case get_credentials() {
    Ok(option.Some(_)) -> True
    _ -> False
  }
}

/// Get credentials or fail with an error
/// 
/// This is a convenience function for cases where you want to fail
/// fast if credentials are not available.
pub fn require_credentials() -> Result(Credentials, CredentialError) {
  case get_credentials() {
    Ok(option.Some(creds)) -> Ok(creds)
    Ok(option.None) -> Error(NoCredentials)
    Error(e) -> Error(e)
  }
}