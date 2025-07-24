import gleam/option.{type Option}

pub type Credentials {
  Credentials(
    credential_provider: String,
    access_key_id: String,
    secret_access_key: String,
    token: Option(String),
    region: Option(String),
  )
}

pub type CredentialError {
  NoCredentials
  ServiceNotStarted
  FetchError(reason: String)
}

pub opaque type RefreshOptions {
  RefreshOptions(options: List(#(String, String)))
}

pub fn new_refresh_options() -> RefreshOptions {
  RefreshOptions([])
}

pub fn with_option(
  options: RefreshOptions,
  key: String,
  value: String,
) -> RefreshOptions {
  let RefreshOptions(opts) = options
  RefreshOptions([#(key, value), ..opts])
}

pub fn get_options(options: RefreshOptions) -> List(#(String, String)) {
  let RefreshOptions(opts) = options
  opts
}