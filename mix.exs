defmodule EvilTransform.Mixfile do
  use Mix.Project

  def project do
    [
      app: :evil_transform,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
    ]
  end

  def package() do
    [
      maintainers: [" Yin Weijun "],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/weij/eviltransform"}
    ]  
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.16.2"},
    ]
  end
end
