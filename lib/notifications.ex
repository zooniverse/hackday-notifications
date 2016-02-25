defmodule Notifications do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Notifications.Endpoint, []),
      supervisor(Notifications.Repo, []),

      # Not yet enabled. For now ZooEventStats will just make HTTP POSTs (like we do for Pusher too)
      # worker(Notifications.Streamer, ["zooniverse-production"]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Notifications.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Notifications.Endpoint.config_change(changed, removed)
    :ok
  end
end
