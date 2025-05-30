defmodule BasicContexts.MixProject do
  use Mix.Project

  @description"""
  BasicContexts on ecto.
  """
  
  def project do
    [
      app: :basic_contexts,
      version: "0.1.8",
      elixir: "~> 1.14",
      description: @description,
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def package do
    [
      maintainers: ["kjsd"],
      licenses: ["BSD-2-Clause"],
      links: %{ "Github": "https://github.com/kjsd/basic_contexts" }
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:ecto, "~> 3.12"},
      {:calendar, "~> 1.0"},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
