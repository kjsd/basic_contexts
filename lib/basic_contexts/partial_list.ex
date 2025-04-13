defmodule BasicContexts.PartialList do
  defmacro __using__(opts) do
    {repo_, pn_, s_, o_} = {opts[:repo], opts[:plural], opts[:plural], opts[:schema],
                            opts[:order_by]}
    
    wfn_ = Keyword.get(opts, :where_fn, Macro.escape(&__MODULE__.nop_/2))
    lfn_ = Keyword.get(opts, :last_fn, Macro.escape(&__MODULE__.nop_/2))

    quote do
      def unquote(:"list_#{pn_}")(range \\ nil, where \\ %{}, args \\ %{}) do
        list_fn = fn ->
          {range, _} = info = unquote(:"list_info_#{pn_}")(range, where)
          query = unquote(:"list_last_query_#{pn_}")(range, where, args)

          {unquote(repo_).all(query), info}
        end

        with {:ok, result} <- unquote(repo_).transaction(list_fn) do
          result
        end
      end

      def unquote(:"stream_#{pn_}")(tr_fn) when is_function(tr_fn) do
        unquote(:"stream_#{pn_}")(nil, %{}, %{}, tr_fn)
      end
      def unquote(:"stream_#{pn_}")(where, tr_fn) when is_function(tr_fn) do
        unquote(:"stream_#{pn_}")(nil, where, %{}, tr_fn)
      end
      def unquote(:"stream_#{pn_}")(where, args, tr_fn) when is_function(tr_fn) do
        unquote(:"stream_#{pn_}")(nil, where, args, tr_fn)
      end
      def unquote(:"stream_#{pn_}")(range, where, args, tr_fn)
      when is_function(tr_fn) do
        stream =
          unquote(:"list_last_query_#{pn_}")(range, where, args)
          |> Ecto.Query.exclude(:preload)
          |> unquote(repo_).stream()

        unquote(repo_).transaction(fn -> tr_fn.(stream) end)
      end

      def unquote(:"list_info_#{pn_}")(range, where \\ %{})
      def unquote(:"list_info_#{pn_}")(nil, where) do
        size = unquote(:"list_size_#{pn_}")(where)
        {nil, size}
      end
      def unquote(:"list_info_#{pn_}")(%Range{} = range, where) do
        size = unquote(:"list_size_#{pn_}")(where)
        range = if range.first < 0, do: 0..range.last, else: range

        case size do
          0 ->
            {nil, size}
          _ ->
            all = 0..(size - 1)
            range =
              with %Range{first: f, last: l} = r when l >= 0 <- range do
                cond do
                  Range.disjoint?(all, r) ->
                    r
                  true ->
                    l = if Enum.member?(all, l), do: l, else: all.last
                    f..l
                end
              else
                _ -> range.first..(all.last)
              end
            {range, size}
        end
      end

      def unquote(:"list_size_#{pn_}")(where \\ %{}) do
        unquote(:"list_query_#{pn_}")(where)
        |> Ecto.Query.select([t], count())
        |> unquote(repo_).one()
      end

      def unquote(:"list_query_#{pn_}")(where \\ %{}) do
        from(t in unquote(s_))
        |> unquote(wfn_).(where)
      end

      def unquote(:"list_last_query_#{pn_}")(range, where \\ %{}, args \\ %{}) do
        range_query = fn q, r ->
          case r do
            %Range{} ->
              q = if r.last >= 0, do: q |> limit(^(Enum.count(r))), else: q
              if r.first > 0, do: q |> offset(^r.first), else: q
            _ ->
              q
          end
        end

        unquote(:"list_query_#{pn_}")(where)
        |> Ecto.Query.order_by(unquote(o_))
        |> unquote(lfn_).(args)
        |> range_query.(range)
      end
    end
  end

  def nop_(query, _args), do: query
end
