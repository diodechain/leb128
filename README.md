# LEB128

LEB128 is a library for encoding and decoding LEB128 encoded numbers. LEB128 is a variable-length encoding for integers that is used in the WebAssembly binary format.

https://en.wikipedia.org/wiki/LEB128

## Installation

The package can be installed by adding `leb128` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:leb128, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
iex> LEB128.encode_unsigned(624_485)
<<0xE5, 0x8E, 0x26>>

iex> LEB128.decode_unsigned!(<<0xE5, 0x8E, 0x26>>)
{624_485, ""}

iex> LEB128.decode_unsigned!(<<0xE5, 0x8E>>)
{:error, :incomplete}
```
