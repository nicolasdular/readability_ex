defmodule ReadabilityEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :readability_ex,
      version: "0.1.11",
      elixir: "~> 1.18",
      config_path: "config/config.exs",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Readability extraction backed by Rust.",
      package: package(),
      source_url: "https://github.com/nicolasdular/readability_ex",
      homepage_url: "https://github.com/nicolasdular/readability_ex"
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
      {:rustler, "~> 0.37", optional: true},
      {:rustler_precompiled, "~> 0.8"},
      {:floki, "~> 0.36"}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/nicolasdular/readability_ex"
      },
      files: [
        "lib",
        "native/readability_ex",
        "mix.exs",
        "README.md",
        "LICENSE",
        "checksum-Elixir.ReadabilityEx.exs"
      ]
    ]
  end
end
