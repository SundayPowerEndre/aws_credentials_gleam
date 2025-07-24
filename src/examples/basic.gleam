/// Basic example of using aws_credentials_gleam
import aws_credentials
import gleam/io
import gleam/option
import gleam/string

pub fn main() {
  io.println("Starting AWS Credentials example...")
  
  // Start the credentials service
  case aws_credentials.start() {
    Ok(_) -> {
      io.println("✓ Credentials service started")
      demo_credentials()
    }
    Error(e) -> {
      io.println("✗ Failed to start credentials service: " <> string.inspect(e))
    }
  }
}

fn demo_credentials() {
  // Check if we have credentials
  io.println("\nChecking for credentials...")
  let has_creds = aws_credentials.has_credentials()
  io.println("Has credentials: " <> string.inspect(has_creds))
  
  // Get credentials
  io.println("\nFetching credentials...")
  case aws_credentials.get_credentials() {
    Ok(option.Some(creds)) -> {
      io.println("✓ Credentials found!")
      io.println("  Provider: " <> creds.credential_provider)
      io.println("  Access Key ID: " <> string.slice(creds.access_key_id, 0, 10) <> "...")
      
      case creds.region {
        option.Some(region) -> io.println("  Region: " <> region)
        option.None -> io.println("  Region: Not specified")
      }
      
      case creds.token {
        option.Some(_) -> io.println("  Session Token: Present")
        option.None -> io.println("  Session Token: Not present")
      }
    }
    Ok(option.None) -> {
      io.println("⚠ No credentials found")
      io.println("  Make sure you have configured AWS credentials via:")
      io.println("  - Environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)")
      io.println("  - AWS credentials file (~/.aws/credentials)")
      io.println("  - IAM role (for EC2/ECS/Lambda)")
    }
    Error(e) -> {
      io.println("✗ Error fetching credentials: " <> string.inspect(e))
    }
  }
  
  // Try to force refresh
  io.println("\nForcing credential refresh...")
  case aws_credentials.force_refresh() {
    Ok(option.Some(_)) -> io.println("✓ Credentials refreshed successfully")
    Ok(option.None) -> io.println("⚠ No credentials found after refresh")
    Error(e) -> io.println("✗ Refresh failed: " <> string.inspect(e))
  }
  
  // Clean up
  io.println("\nStopping credentials service...")
  aws_credentials.stop()
  io.println("✓ Done")
}