defmodule BasicContexts do
  defmacro __using__(opts) do
    repo = Keyword.get(opts, :repo)
    Keyword.get(opts, :funcs, [:all, :get, :create, :update, :delete, :change])
    |> Enum.map(&(apply(__MODULE__, &1, [repo, opts[:attrs]])))
  end
  
  def all(repo_, opts) do
    {pn_, s_, o_, p_} = {opts[:plural], opts[:schema], opts[:order_by],
                         Keyword.get(opts, :preload, [])}
    quote do
      import Ecto.Query, warn: false

      def unquote(:"all_#{pn_}")() do
        unquote(s_)
        |> Ecto.Query.order_by(unquote(o_))
        |> Ecto.Query.preload(unquote(p_))
        |> unquote(repo_).all()
      end
    end
  end

  def get(repo_, opts) do
    {sn_, s_, p_} = {opts[:singular], opts[:schema], Keyword.get(opts, :preload, [])}
    quote do
      def unquote(:"get_#{sn_}")(id, opts \\ []) do
        unquote(repo_).get(unquote(s_), id, opts)
        |> unquote(repo_).preload(unquote(p_))
      end
      def unquote(:"get_#{sn_}!")(id, opts \\ []) do
        unquote(repo_).get(unquote(s_), id, opts)
        |> unquote(repo_).preload(unquote(p_))
      end
    end
  end
  
  def create(repo_, opts) do
    {sn_, s_, p_} = {opts[:singular], opts[:schema], Keyword.get(opts, :preload, [])}
    quote do
      alias unquote(repo_)

      def unquote(:"create_#{sn_}")(attrs \\ %{}, opts \\ []) do
        result = %unquote(s_){}
        |> unquote(s_).changeset(attrs)
        |> unquote(repo_).insert(opts)

        with {:ok, o} <- result do
          {:ok, unquote(repo_).preload(o, unquote(p_))}
        end
      end
    end
  end

  def update(repo_, opts) do
    {sn_, s_, p_} = {opts[:singular], opts[:schema], Keyword.get(opts, :preload, [])}
    quote do
      def unquote(:"update_#{sn_}")(%unquote(s_){} = o, attrs, opts \\ []) do
        result = o
        |> unquote(s_).changeset(attrs)
        |> unquote(repo_).update(opts)

        with {:ok, o} <- result do
          {:ok, unquote(repo_).preload(o, unquote(p_), force: true)}
        end
      end
    end
  end
  
  def delete(repo_, opts) do
    {sn_, s_} = {opts[:singular], opts[:schema]}
    quote do
      def unquote(:"delete_#{sn_}")(o, opts \\ [])
      def unquote(:"delete_#{sn_}")(nil, _), do: {:ok, nil}
      def unquote(:"delete_#{sn_}")(%unquote(s_){} = o, opts) do
        unquote(repo_).delete(o, opts)
      end
    end
  end
  
  def change(_, opts) do
    {sn_, s_} = {opts[:singular], opts[:schema]}
    quote do
      def unquote(:"change_#{sn_}")(%unquote(s_){} = o, attrs \\ %{}) do
        unquote(s_).changeset(o, attrs)
      end
    end
  end
end
