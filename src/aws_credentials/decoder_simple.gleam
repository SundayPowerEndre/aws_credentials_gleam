import gleam/bit_array
import gleam/dynamic.{type Dynamic}
import gleam/erlang/atom.{type Atom}
import gleam/option.{type Option, None, Some}
import gleam/string
import aws_credentials/types.{type Credentials, Credentials}

@external(erlang, "erlang", "is_atom")
fn is_atom(value: Dynamic) -> Bool

@external(erlang, "erlang", "is_map")
fn is_map(value: Dynamic) -> Bool

@external(erlang, "erlang", "is_tuple")
fn is_tuple(value: Dynamic) -> Bool

@external(erlang, "erlang", "atom_to_binary")
fn atom_to_binary(atom: Atom, encoding: Atom) -> BitArray

@external(erlang, "gleam_stdlib", "identity")
fn unsafe_coerce_atom(value: Dynamic) -> Atom

@external(erlang, "maps", "get")
fn maps_get(key: Atom, map: Dynamic, default: Dynamic) -> Dynamic

@external(erlang, "maps", "is_key")
fn maps_is_key(key: Atom, map: Dynamic) -> Bool

pub fn dynamic_to_atom_string(value: Dynamic) -> Result(String, String) {
  case is_atom(value) {
    True -> {
      let a = unsafe_coerce_atom(value)
      let utf8 = atom.create("utf8")
      let bits = atom_to_binary(a, utf8)
      case bit_array.to_string(bits) {
        Ok(s) -> Ok(s)
        Error(_) -> Error("Invalid UTF-8 in atom")
      }
    }
    False -> Error("Not an atom")
  }
}

fn dynamic_to_string(value: Dynamic) -> Result(String, String) {
  let bits = unsafe_coerce_bitarray(value)
  case bit_array.to_string(bits) {
    Ok(s) -> Ok(s)
    Error(_) -> Error("Invalid UTF-8 string")
  }
}

@external(erlang, "gleam_stdlib", "identity")
fn unsafe_coerce_bitarray(value: Dynamic) -> BitArray

@external(erlang, "gleam_stdlib", "identity")
fn unsafe_coerce_tuple2(value: Dynamic) -> #(Dynamic, Dynamic)

fn undefined_dynamic() -> Dynamic {
  atom.to_dynamic(atom.create("undefined"))
}

pub fn decode_credentials(data: Dynamic) -> Result(Option(Credentials), String) {
  case dynamic_to_atom_string(data) {
    Ok("undefined") -> Ok(None)
    _ -> {
      case is_map(data) {
        True -> decode_map(data)
        False -> Error("Expected map or undefined atom")
      }
    }
  }
}

fn decode_map(data: Dynamic) -> Result(Option(Credentials), String) {
  let provider_key = atom.create("credential_provider")
  let access_key = atom.create("access_key_id")
  let secret_key = atom.create("secret_access_key")
  let token_key = atom.create("token")
  let region_key = atom.create("region")
  
  let provider = maps_get(provider_key, data, undefined_dynamic())
  let access = maps_get(access_key, data, undefined_dynamic())
  let secret = maps_get(secret_key, data, undefined_dynamic())
  
  case dynamic_to_atom_string(provider), dynamic_to_string(access), dynamic_to_string(secret) {
    Ok(p), Ok(a), Ok(s) -> {
      let token = case maps_is_key(token_key, data) {
        True -> {
          let t = maps_get(token_key, data, undefined_dynamic())
          case dynamic_to_string(t) {
            Ok(str) -> Some(str)
            Error(_) -> None
          }
        }
        False -> None
      }
      
      let region = case maps_is_key(region_key, data) {
        True -> {
          let r = maps_get(region_key, data, undefined_dynamic())
          case dynamic_to_string(r) {
            Ok(str) -> Some(str)
            Error(_) -> None
          }
        }
        False -> None
      }
      
      Ok(Some(Credentials(
        credential_provider: p,
        access_key_id: a,
        secret_access_key: s,
        token: token,
        region: region,
      )))
    }
    _, _, _ -> Error("Failed to decode required fields")
  }
}

pub fn decode_refresh_result(data: Dynamic) -> Result(Option(Credentials), String) {
  case decode_credentials(data) {
    Ok(result) -> Ok(result)
    Error(_) -> {
      case is_tuple(data) {
        True -> {
          let #(first, second) = unsafe_coerce_tuple2(data)
          case dynamic_to_atom_string(first) {
            Ok("error") -> Error("Refresh error: " <> string.inspect(second))
            _ -> Error("Unexpected tuple: " <> string.inspect(data))
          }
        }
        False -> Error("Unexpected result: " <> string.inspect(data))
      }
    }
  }
}