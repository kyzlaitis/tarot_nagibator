## Define build arguments for Elixir, OTP, and Debian versions.
ARG ELIXIR_VERSION=1.17.3
ARG OTP_VERSION=27.1
ARG DEBIAN_VERSION=bullseye-20240926-slim

# Define common images to be used for both development and production
ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

# --- BUILD STAGE ---
FROM ${BUILDER_IMAGE} as builder

# Install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Prepare build directory
WORKDIR /app

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV="prod"

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# Copy compile-time config files before compiling dependencies
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv
COPY lib lib
COPY assets assets

# Compile assets (only for production)
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Changes to runtime config don't require recompilation
COPY config/runtime.exs config/
COPY rel rel
RUN mix release

# --- DEVELOPMENT STAGE ---
FROM ${BUILDER_IMAGE} as dev

# Install Node.js (required for Phoenix LiveReload & asset management)
RUN apt-get update && apt-get install -y nodejs npm inotify-tools \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set working directory
WORKDIR /app

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set development ENV
ENV MIX_ENV="dev"

# Copy all project files
COPY . .

# Install dependencies
RUN mix deps.get

# Install npm dependencies for assets
RUN cd assets && npm install

# Expose port for development
EXPOSE 4000

# Default command for development
CMD ["mix", "phx.server"]

# --- PRODUCTION STAGE ---
FROM ${RUNNER_IMAGE} as prod

RUN apt-get update -y && \
  apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# Set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/tarot_nagibator ./

USER nobody

# Default command for production
CMD ["/app/bin/server"]

# --- USAGE INSTRUCTIONS ---
# For development, you can build and run the 'dev' stage:
#   docker build --target dev -t myapp-dev .
#   docker run -p 4000:4000 myapp-dev
#
# For production, you can build and run the 'prod' stage:
#   docker build --target prod -t myapp-prod .
#   docker run -p 4000:4000 myapp-prod
