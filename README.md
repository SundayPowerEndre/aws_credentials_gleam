# AWS Credentials for Gleam

A type-safe Gleam wrapper for the battle-tested `aws_credentials` Erlang library. This package provides automatic AWS credential management with support for multiple credential sources.

## Features

- 🔐 **Multiple credential sources**: Environment variables, AWS credential files, ECS, EC2 instance metadata, and EKS
- 🔄 **Automatic credential refresh**: Credentials are automatically refreshed before expiration
- 🎯 **Type-safe API**: Leverages Gleam's type system for compile-time safety
- 🔧 **Zero configuration**: Works out of the box with standard AWS credential chains
- ⚡ **Battle-tested**: Built on top of the proven `aws_credentials` Erlang library

## Installation

Add `aws_credentials_gleam` to your `gleam.toml`:

```toml
[dependencies]
aws_credentials_gleam = "~> 1.0"
# Note: You'll also need the aws_credentials Erlang library
# This would typically come from your rebar.config or mix.exs
```

For Erlang projects, add to your `rebar.config`:
```erlang
{deps, [
    {aws_credentials, "0.3.0"}
]}.
```

For Elixir projects, add to your `mix.exs`:
```elixir
defp deps do
  [
    {:aws_credentials, "~> 0.3.0"}
  ]
end
```

## Quick Start

```gleam
import aws_credentials
import gleam/io
import gleam/option

pub fn main() {
  // Start the credentials service
  let assert Ok(_) = aws_credentials.start()
  
  // Get credentials
  case aws_credentials.get_credentials() {
    Ok(option.Some(creds)) -> {
      io.println("Access Key: " <> creds.access_key_id)
      io.println("Provider: " <> creds.credential_provider)
    }
    Ok(option.None) -> io.println("No credentials found")
    Error(e) -> io.println("Error: " <> string.inspect(e))
  }
  
  // Stop the service when done
  aws_credentials.stop()
}
```

## Credential Sources

The library checks for credentials in the following order:

1. **Environment Variables**
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_SESSION_TOKEN` (optional)
   - `AWS_REGION` (optional)

2. **AWS Credential Files**
   - Default: `~/.aws/credentials` and `~/.aws/config`
   - Supports profiles via `AWS_PROFILE` environment variable
   - Supports `credential_process` for external credential providers

3. **ECS Container Credentials**
   - Automatically detected via `AWS_CONTAINER_CREDENTIALS_RELATIVE_URI`

4. **EC2 Instance Metadata**
   - Uses IMDSv2 for enhanced security
   - Automatically fetches credentials from instance IAM role

5. **EKS Pod Identity**
   - Uses `AWS_CONTAINER_CREDENTIALS_FULL_URI`
   - Reads auth token from `AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE`

## API Reference

### Core Functions

#### `start() -> Result(Nil, CredentialError)`
Start the credential management service. This must be called before using other functions.

#### `stop() -> Nil`
Stop the credential management service.

#### `get_credentials() -> Result(Option(Credentials), CredentialError)`
Get the current cached credentials. Returns `None` if no credentials are available.

#### `force_refresh() -> Result(Option(Credentials), CredentialError)`
Force a refresh of credentials, bypassing the cache.

#### `has_credentials() -> Bool`
Check if valid credentials are available.

#### `require_credentials() -> Result(Credentials, CredentialError)`
Get credentials or return an error if none are available.

### Types

```gleam
pub type Credentials {
  Credentials(
    credential_provider: String,    // The provider that supplied the credentials
    access_key_id: String,         // AWS Access Key ID
    secret_access_key: String,     // AWS Secret Access Key
    token: Option(String),         // Session token (for temporary credentials)
    region: Option(String),        // AWS region
  )
}

pub type CredentialError {
  NoCredentials                  // No credentials found in any provider
  ServiceNotStarted             // The credential service is not running
  FetchError(reason: String)    // Error occurred while fetching credentials
}
```

## Advanced Usage

### Custom Refresh Options

```gleam
import aws_credentials
import aws_credentials/types

pub fn refresh_with_profile() {
  let options = 
    types.new_refresh_options()
    |> types.with_option("profile", "production")
  
  case aws_credentials.force_refresh_with_options(options) {
    Ok(option.Some(creds)) -> // Use credentials
    Ok(option.None) -> // No credentials found
    Error(e) -> // Handle error
  }
}
```

### Integration with AWS SDK

This library is designed to work seamlessly with AWS SDK implementations for BEAM languages:

```gleam
import aws_credentials
import some_aws_sdk

pub fn upload_to_s3() {
  let assert Ok(creds) = aws_credentials.require_credentials()
  
  let client = some_aws_sdk.new_client(
    creds.access_key_id,
    creds.secret_access_key,
    creds.token,
    creds.region,
  )
  
  // Use the client for AWS operations
}
```

## Configuration

The underlying `aws_credentials` library can be configured via Erlang application environment:

```erlang
% In your sys.config or app config
[
  {aws_credentials, [
    {credential_providers, [aws_credentials_env, aws_credentials_file]},
    {fail_if_unavailable, false}
  ]}
]
```

## Development

This library requires the `aws_credentials` Erlang application to be available. When developing locally, ensure you have the AWS Erlang ecosystem in your dependencies.

## License

Apache 2.0 - See LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.