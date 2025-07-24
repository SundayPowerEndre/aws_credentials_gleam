/// Types for AWS credentials
import gleam/option.{type Option}

/// AWS Credentials containing access keys and optional session token
pub type Credentials {
  Credentials(
    /// The credential provider that supplied these credentials
    credential_provider: String,
    /// AWS access key ID
    access_key_id: String,
    /// AWS secret access key
    secret_access_key: String,
    /// Optional session token for temporary credentials
    token: Option(String),
    /// Optional AWS region
    region: Option(String),
  )
}

/// Error types that can occur when fetching credentials
pub type CredentialError {
  /// No credentials could be found in any provider
  NoCredentials
  /// The credentials service is not started
  ServiceNotStarted
  /// An error occurred while fetching credentials
  FetchError(reason: String)
}

/// Options that can be passed to force refresh
pub opaque type RefreshOptions {
  RefreshOptions(options: List(#(String, String)))
}

/// Create empty refresh options
pub fn new_refresh_options() -> RefreshOptions {
  RefreshOptions([])
}

/// Add an option to refresh options
pub fn with_option(
  options: RefreshOptions,
  key: String,
  value: String,
) -> RefreshOptions {
  let RefreshOptions(opts) = options
  RefreshOptions([#(key, value), ..opts])
}

/// Get the options list (for internal use)
pub fn get_options(options: RefreshOptions) -> List(#(String, String)) {
  let RefreshOptions(opts) = options
  opts
}