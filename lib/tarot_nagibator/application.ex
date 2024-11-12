defmodule TarotNagibator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TarotNagibatorWeb.Telemetry,
      TarotNagibator.Repo,
      {DNSCluster, query: Application.get_env(:tarot_nagibator, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TarotNagibator.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: TarotNagibator.Finch},
      # Start a worker by calling: TarotNagibator.Worker.start_link(arg)
      # {TarotNagibator.Worker, arg},
      # Start to serve requests, typically the last entry
      TarotNagibatorWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TarotNagibator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TarotNagibatorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
