defmodule BasicContexts.PartialListTest do
  use ExUnit.Case
  doctest BasicContexts.PartialList

  import Ecto.Query, warn: false
  import BasicContexts.Query

  alias BasicContexts.PartialList
  
  setup_all do
    defmodule Repo do
    end
    defmodule Schema do
    end
    
    defmodule Impl do
      use PartialList, repo: PartialListTest.Repo, plural: :schemas,
        schema: PartialListTest.Schema,
        where_fn: fn query, attrs ->
        query
        |> add_if(attrs[:attr], &(&2 |> where([t], t.attr == ^&1)))
      end
    end
    |> elem(1)
    |> then(&({:ok, %{impl: &1}}))
  end
end
