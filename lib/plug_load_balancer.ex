defmodule PlugLoadBalancer do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(PlugLoadBalancer.Config, config_args()),
      # PlugLoadBalancer.Api.spec(...),
      # PlugLoadBalancer.Proxy.spec(...),
      # supervisor(PlugLoadBalancer.HealthCheck, []),
    ]

    opts = [strategy: :one_for_one, name: PlugLoadBalancer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp config_args do
    rules = Application.get_env(:plug_load_balancer, :routes, [])
    [PlugLoadBalancer.Config, [rules: rules]]
  end
end
