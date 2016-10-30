defmodule Ballast.Config.Rule do

  @default_host :_
  @default_path :_
  @default_plug Ballast.Plug.Default
  @default_opts []

  defstruct [host: :_, path: :_, prefix: nil, plug: @default_plug, plug_opts: @default_opts]

  def new(opts \\ []) do
    struct!(__MODULE__, opts)
  end

  @cowboy_handler Plug.Adapters.Cowboy.Handler

  def to_route(rule = %__MODULE__{prefix: nil}) do
    opts = rule.plug.init(rule.plug_opts)
    opts = Ballast.ProxyEndpoint.init(plug: {rule.plug, opts})
    to_cowboy_route(rule.host, rule.path, opts)
  end

  def to_route(rule = %__MODULE__{}) do
    opts = rule.plug.init(rule.plug_opts)
    opts = Ballast.Plug.Prefix.init(path: rule.prefix, plug: {rule.plug, opts})
    opts = Ballast.ProxyEndpoint.init(plug: {Ballast.Plug.Prefix, opts})
    to_cowboy_route(rule.host, rule.path, opts)
  end

  defp to_cowboy_route(host, path, opts) do
    {to_char_route(host), [{to_char_route(path),
                            @cowboy_handler,
                            {Ballast.ProxyEndpoint, opts}}]}
  end

  defp to_char_route(nil), do: :_
  defp to_char_route(:_), do: :_
  defp to_char_route(s), do: to_char_list(s)
end

defimpl Poison.Encoder, for: Ballast.Config.Rule do
  alias Ballast.Config.Rule

  def encode(rule = %Rule{path: :_}, opts) do
    Poison.Encoder.Map.encode(%{host: rule.host}, opts)
  end

  def encode(rule = %Rule{host: :_}, opts) do
    Poison.Encoder.Map.encode(%{path: rule.path}, opts)
  end

  def encode(rule = %Rule{}, opts) do
    Poison.Encoder.Map.encode(%{host: rule.host, path: rule.path}, opts)
  end
end
