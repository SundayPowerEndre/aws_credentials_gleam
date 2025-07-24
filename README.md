# aws_credentials_gleam

Type-safe AWS credentials management for Gleam, built on top of the robust [aws_credentials](https://hex.pm/packages/aws_credentials) Erlang library.

**Note:** This is an independent project that provides Gleam bindings for AWS credential management. It is not affiliated with the aws-erlang project.

## Quick Start

### Installation

```sh
gleam add aws_credentials_gleam
```

### Usage

```gleam
import gleam/io
import gleam/option
import gleam/string
import aws_credentials_client as aws

pub fn main() {
  // Start the credentials service
  case aws.start() {
    Ok(_) -> {
      io.println("AWS credentials service started successfully")
      
      // Get current credentials
      case aws.get_credentials() {
        Ok(option.Some(creds)) -> {
          io.println("Found AWS credentials:")
          io.println("  Access Key ID: " <> creds.access_key_id)
          io.println("  Provider: " <> creds.credential_provider)
        }
        Ok(option.None) -> io.println("No AWS credentials found")
        Error(err) -> io.println("Error: " <> string.inspect(err))
      }
    }
    Error(err) -> {
      io.println("Failed to start: " <> string.inspect(err))
    }
  }
}
```

## Features

- **Type-safe** credential management with Gleam's type system
- **Automatic credential discovery** from multiple sources:
  - Environment variables
  - AWS credentials file (`~/.aws/credentials`)
  - IAM roles (EC2, ECS, EKS)
- **Automatic refresh** of expiring credentials
- **Zero configuration** - just start and use

## API

- `start() -> Result(Nil, CredentialError)` - Start the credentials service
- `get_credentials() -> Result(Option(Credentials), CredentialError)` - Get current credentials
- `has_credentials() -> Bool` - Check if credentials are available
- `force_refresh() -> Result(Option(Credentials), CredentialError)` - Force credential refresh
- `stop() -> Nil` - Stop the credentials service

## Credits

This project is built on top of the excellent [aws_credentials](https://hex.pm/packages/aws_credentials) library from the [aws-erlang](https://github.com/aws-beam/aws-erlang) project. If you find this Gleam wrapper useful, please consider supporting the underlying aws-erlang project:

- ⭐ Star the [aws-erlang repository](https://github.com/aws-beam/aws-erlang)

## License

Apache 2.0
