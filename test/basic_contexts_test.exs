defmodule BasicContexts.BasicContextsTest do
  use ExUnit.Case
  doctest BasicContexts

  setup_all do
    defmodule Repo do
    end
    defmodule Schema do
    end
    
    defmodule Impl do
      use BasicContexts, repo: BasicContextsTest.Repo,
        attrs: [singular: :schema, plural: :schemas, schema: BasicContextsTest.Schema]
    end
    |> elem(1)
    |> then(&({:ok, %{impl: &1}}))
  end
end
