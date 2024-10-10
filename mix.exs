defmodule Leb128.MixProject do
  use Mix.Project

  @url "https://github.com/diodechain/leb128"
  def project do
    [
      app: :leb128,
      version: "1.0.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: "LEB128 is a library for encoding and decoding LEB128 encoded numbers.",
      package: [
        licenses: ["Apache 2.0"],
        maintainers: ["Dominic Letz"],
        links: %{"GitHub" => @url}
      ],
      # Docs
      name: "LEB128",
      source_url: @url,
      docs: [
        # The main page in the docs
        main: "LEB128",
        extras: ["README.md"]
      ]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end
end
