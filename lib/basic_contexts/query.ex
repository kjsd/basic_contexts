defmodule BasicContexts.Query do
  defmacro like_sanitize(v) do
    quote do
      Regex.replace(~r/([%_])/, unquote(v), ~S"\\\1")
    end
  end

  defmacro add_if(acc, x, fun) do
    quote bind_quoted: [acc: acc, x: x, fun: fun] do
      case x do
        nil ->
          acc
        "" ->
          acc
        [] ->
          acc
        _ ->
          fun.(x, acc)
      end
    end
  end
end
