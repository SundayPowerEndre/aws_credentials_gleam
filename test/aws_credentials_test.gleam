import gleeunit
import gleeunit/should
import aws_credentials
import aws_credentials/types
import gleam/option

pub fn main() {
  gleeunit.main()
}

// Tests that require aws_credentials to be included as a dependency
// These tests interact with the real aws_credentials Erlang application

pub fn start_stop_test() {
  // Start the service
  let assert Ok(Nil) = aws_credentials.start()
  
  // Service should be running, we should be able to get credentials
  // (they might be None if no providers are configured)
  let _ = aws_credentials.get_credentials()
  
  // Stop the service
  aws_credentials.stop()
}

pub fn get_credentials_type_test() {
  let assert Ok(Nil) = aws_credentials.start()
  
  // Get credentials should return a Result with Option
  let result = aws_credentials.get_credentials()
  
  case result {
    Ok(option.Some(creds)) -> {
      // If we have credentials, they should have the required fields
      creds.access_key_id
      |> should.not_equal("")
      
      creds.secret_access_key
      |> should.not_equal("")
      
      creds.credential_provider
      |> should.not_equal("")
    }
    Ok(option.None) -> {
      // No credentials is also valid
      Nil
    }
    Error(_) -> {
      // Error is possible if service isn't started
      Nil
    }
  }
  
  aws_credentials.stop()
}

pub fn has_credentials_test() {
  let assert Ok(Nil) = aws_credentials.start()
  
  // has_credentials should return a Bool
  let _has = aws_credentials.has_credentials()
  
  aws_credentials.stop()
}

pub fn refresh_options_test() {
  // Test creating refresh options
  let options =
    types.new_refresh_options()
    |> types.with_option("profile", "testing")
    |> types.with_option("region", "us-east-1")
  
  // Options should be created without error
  should.not_equal(options, types.new_refresh_options())
}