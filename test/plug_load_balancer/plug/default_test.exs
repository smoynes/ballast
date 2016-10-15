defmodule PlugLoadBalancer.Plug.DefaultTest do
  use ExUnit.Case, async: true
  use Plug.Test

  describe "PlugLoader.Plug.Default.call/2" do
    alias PlugLoadBalancer.Plug.Default

    @default_plug Default.init([])

    test "returns default response" do
      conn =
        conn(:get, "/")
        |> Default.call(@default_plug)
      assert conn.status == 200
    end
  end
end
