defmodule ReadabilityEx do
  @moduledoc """
  Extract readable article content from HTML using a Rust NIF.
  """

  @version Mix.Project.config()[:version]

  @base_url_default "https://github.com/nicolasdular/readability_ex/releases/download/v#{@version}"
  @force_build System.get_env("READABILITY_EX_FORCE_BUILD") in ["1", "true"] or Mix.env() != :prod

  use RustlerPrecompiled,
    otp_app: :readability_ex,
    crate: "readability_ex",
    base_url: System.get_env("READABILITY_EX_PRECOMPILED_URL") || @base_url_default,
    force_build: @force_build,
    targets: [
      "aarch64-apple-darwin",
      "aarch64-unknown-linux-gnu",
      "aarch64-unknown-linux-musl",
      "x86_64-apple-darwin",
      "x86_64-unknown-linux-gnu",
      "x86_64-unknown-linux-musl"
    ],
    version: @version

  @spec extract(String.t(), keyword()) :: {:ok, String.t() | nil} | {:error, String.t()}
  def extract(html, opts \\ []) when is_list(opts) do
    base_url = Keyword.get(opts, :base_url)

    case extract_nif(html, base_url) do
      {:ok, nil} ->
        {:ok, nil}

      {:ok, content} ->
        {:ok, maybe_resolve_links(content, base_url)}

      {:error, _reason} = error ->
        error
    end
  end

  defp extract_nif(_html, _url), do: :erlang.nif_error(:nif_not_loaded)

  defp maybe_resolve_links(content, nil), do: content

  defp maybe_resolve_links(content, base_url) do
    with {:ok, base_uri} <- parse_base_uri(base_url),
         {:ok, nodes} <- Floki.parse_fragment(content) do
      nodes
      |> Floki.traverse_and_update(fn
        {tag, attrs, children} ->
          {tag, rewrite_attrs(tag, attrs, base_uri), children}

        other ->
          other
      end)
      |> Floki.raw_html()
    else
      _ -> content
    end
  end

  defp parse_base_uri(base_url) do
    case URI.parse(base_url) do
      %URI{scheme: scheme, host: host} = uri when is_binary(scheme) and is_binary(host) ->
        {:ok, uri}

      _ ->
        :error
    end
  end

  defp rewrite_attrs(tag, attrs, base_uri) do
    Enum.map(attrs, fn
      {"href", value} when tag in ["a", "link"] ->
        {"href", resolve_url(value, base_uri)}

      {"src", value} when tag in ["img", "audio", "video", "source", "iframe", "embed"] ->
        {"src", resolve_url(value, base_uri)}

      {"data", value} when tag in ["object"] ->
        {"data", resolve_url(value, base_uri)}

      {"poster", value} when tag in ["video"] ->
        {"poster", resolve_url(value, base_uri)}

      {"srcset", value} when tag in ["img", "source"] ->
        {"srcset", resolve_srcset(value, base_uri)}

      other ->
        other
    end)
  end

  defp resolve_url(value, base_uri) when is_binary(value) do
    trimmed = String.trim(value)

    cond do
      trimmed == "" ->
        value

      absolute_or_special?(trimmed) ->
        value

      true ->
        base_uri
        |> URI.merge(trimmed)
        |> URI.to_string()
    end
  end

  defp resolve_url(value, _base_uri), do: value

  defp resolve_srcset(value, base_uri) when is_binary(value) do
    trimmed = String.trim(value)

    if trimmed == "" or String.contains?(trimmed, "data:") do
      value
    else
      trimmed
      |> String.split(",")
      |> Enum.map(&resolve_srcset_entry(&1, base_uri))
      |> Enum.join(", ")
    end
  end

  defp resolve_srcset(value, _base_uri), do: value

  defp resolve_srcset_entry(entry, base_uri) do
    entry = String.trim(entry)

    case String.split(entry, ~r/\s+/, parts: 2, trim: true) do
      [url] ->
        resolve_url(url, base_uri)

      [url, descriptor] ->
        resolved = resolve_url(url, base_uri)
        "#{resolved} #{descriptor}"
    end
  end

  defp absolute_or_special?(value) do
    String.starts_with?(value, ["#", "mailto:", "tel:", "javascript:", "data:"]) or
      match?(%URI{scheme: scheme} when is_binary(scheme), URI.parse(value))
  end
end
