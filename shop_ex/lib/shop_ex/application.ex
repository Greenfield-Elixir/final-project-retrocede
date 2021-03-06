defmodule ShopEx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    :logger.add_primary_filter(
      :ignore_rabbitmq_progress_reports,
      {&:logger_filters.domain/2, {:stop, :equal, [:progress]}}
    )
    children = [
      # Start the Ecto repository
      ShopEx.Repo,
      # Start the Telemetry supervisor
      ShopExWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ShopEx.PubSub},
      # Start the Endpoint (http/https)
      ShopExWeb.Endpoint,
      ShopEx.PublisherPool
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ShopEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ShopExWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
