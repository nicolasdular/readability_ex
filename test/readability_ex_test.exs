defmodule ReadabilityExTest do
  use ExUnit.Case, async: true

  @fixture_path Path.expand("fixtures/article.html", __DIR__)
  @base_url "https://example.com/articles/123"
  @relative_href ~s(href="/hello")
  @absolute_href ~s(href="https://example.com/hello")
  @mailto_href ~s(href="mailto:hello@example.com")

  test "extracts readable content" do
    html = File.read!(@fixture_path)

    assert {:ok, content} = ReadabilityEx.extract(html, base_url: @base_url)
    assert is_binary(content)
    assert content =~ "Sample Article"
    assert content =~ "Hello from ReadabilityEx."
  end

  test "returns main content without crashing on a base url" do
    html = File.read!(@fixture_path)

    assert {:ok, content} = ReadabilityEx.extract(html, base_url: @base_url)
    assert content =~ "Relative link"
  end

  test "resolves relative asset paths in the output" do
    html = File.read!(@fixture_path)

    assert {:ok, content} = ReadabilityEx.extract(html, base_url: @base_url)
    assert content =~ ~s(src="https://example.com/images/hero.jpg")
    assert content =~ ~s(srcset="https://example.com/images/hero.webp")
    assert content =~ ~s(src="https://example.com/images/hero.png")
  end

  test "does not rewrite mailto links" do
    html = File.read!(@fixture_path)

    assert {:ok, content} = ReadabilityEx.extract(html, base_url: @base_url)
    assert content =~ @mailto_href
  end

  test "resolves relative anchor hrefs" do
    html = File.read!(@fixture_path)

    assert {:ok, content} = ReadabilityEx.extract(html, base_url: @base_url)
    assert content =~ @absolute_href
  end

  test "keeps relative links when base url is nil" do
    html = File.read!(@fixture_path)

    assert {:ok, content} = ReadabilityEx.extract(html)
    assert content =~ @relative_href
  end
end
