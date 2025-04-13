defmodule BasicContexts.Constants do
  defmacro constant(name, value) do
    quote do
      defmacro unquote(name), do: unquote(value)
    end
  end

  defmacro define(name, value) do
    quote do
      constant(unquote(name), unquote(value))
    end
  end

  defmacro __using__(_opts) do
    quote do
      import BasicContexts.Constants
    end
  end
end
