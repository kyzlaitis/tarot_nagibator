FROM elixir:latest

# Install Node.js (required for Phoenix)
RUN apt-get update && apt-get install -y nodejs npm inotify-tools

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app
