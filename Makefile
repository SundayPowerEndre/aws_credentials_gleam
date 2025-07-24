.PHONY: all build test clean deps run-example shell docs

all: deps build test

deps:
	@echo "→ Downloading Gleam dependencies..."
	@gleam deps download
	@echo "→ Downloading Erlang dependencies..."
	@rebar3 get-deps

build: deps
	@echo "→ Building project..."
	@gleam build

test: build
	@echo "→ Running tests..."
	@gleam test

clean:
	@echo "→ Cleaning build artifacts..."
	@rm -rf build _build _checkouts
	@rm -rf ebin

run-example: build
	@echo "→ Running example..."
	@gleam run -m examples/basic

# Start an Erlang shell with the project loaded
shell: build
	@echo "→ Starting Erlang shell..."
	@gleam shell

docs:
	@echo "→ Generating documentation..."
	@gleam docs build

# Quick test with mock credentials
test-with-env: build
	@echo "→ Testing with mock environment credentials..."
	@AWS_ACCESS_KEY_ID=test_key AWS_SECRET_ACCESS_KEY=test_secret AWS_REGION=us-east-1 \
		gleam run -m examples/basic

# Format code
format:
	@echo "→ Formatting code..."
	@gleam format

# Check format without changing files
format-check:
	@echo "→ Checking code format..."
	@gleam format --check