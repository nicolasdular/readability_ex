# ReadabilityEx

Readability extraction backed by Rust `readabilityrs`, with Elixir-side URL resolution.

## Usage

```elixir
{:ok, content} = ReadabilityEx.extract(html, base_url: "https://example.com/post")
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `readability_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:readability_ex, "~> 0.1.0"}
  ]
end
```

## Precompiled binaries

This library uses `rustler_precompiled` for optional precompiled NIFs.

- Set `READABILITY_EX_PRECOMPILED_URL` to override the release base URL.
- In dev/test, the NIF builds locally by default. Set `READABILITY_EX_FORCE_BUILD=1` to force a local build in prod.

The default base URL in `ReadabilityEx` is:

```
https://github.com/nicolasdular/readability_ex/releases/download/v#{@version}
```

Replace the base URL if you publish under a different org/user.

## Checksum packaging

After uploading release artifacts, generate the checksum file and include it in the Hex package:

```bash
mix rustler_precompiled.download Elixir.ReadabilityEx --all --print
```

This creates `checksum-Elixir.ReadabilityEx.exs`, which is already listed in `mix.exs` `package.files`.

## Release checklist

1. Tag a release (for example `v0.1.0`) and push the tag.
2. Wait for the GitHub Actions workflow to upload NIF artifacts to the release.
3. Generate and commit the checksum file:

```bash
mix rustler_precompiled.download Elixir.ReadabilityEx --all --print
```

4. Publish to Hex:

```bash
mix hex.publish
```
