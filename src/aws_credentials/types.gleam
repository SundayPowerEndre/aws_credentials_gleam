import gleam/option.{type Option}
import gleam/list
import gleam/int

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
  ServiceNotStarted(reason: String)
  FetchError(reason: String)
}

pub type RefreshOption {
  Provider(String)
  Region(String)
  RoleArn(String)
  SessionName(String)
  ExternalId(String)
  DurationSeconds(Int)
  CustomOption(key: String, value: String)
}

pub opaque type RefreshOptions {
  RefreshOptions(options: List(RefreshOption))
}

pub fn new_refresh_options() -> RefreshOptions {
  RefreshOptions([])
}

pub fn with_option(
  options: RefreshOptions,
  option: RefreshOption,
) -> RefreshOptions {
  let RefreshOptions(opts) = options
  RefreshOptions([option, ..opts])
}

pub fn with_provider(options: RefreshOptions, provider: String) -> RefreshOptions {
  with_option(options, Provider(provider))
}

pub fn with_region(options: RefreshOptions, region: String) -> RefreshOptions {
  with_option(options, Region(region))
}

pub fn with_role_arn(options: RefreshOptions, role_arn: String) -> RefreshOptions {
  with_option(options, RoleArn(role_arn))
}

pub fn with_session_name(options: RefreshOptions, session_name: String) -> RefreshOptions {
  with_option(options, SessionName(session_name))
}

pub fn to_erlang_options(options: RefreshOptions) -> List(#(String, String)) {
  let RefreshOptions(opts) = options
  opts
  |> list.map(fn(opt) {
    case opt {
      Provider(p) -> #("provider", p)
      Region(r) -> #("region", r)
      RoleArn(arn) -> #("role_arn", arn)
      SessionName(name) -> #("session_name", name)
      ExternalId(id) -> #("external_id", id)
      DurationSeconds(secs) -> #("duration_seconds", int.to_string(secs))
      CustomOption(key, value) -> #(key, value)
    }
  })
}

@deprecated("Use to_erlang_options instead")
pub fn get_options(options: RefreshOptions) -> List(#(String, String)) {
  to_erlang_options(options)
}