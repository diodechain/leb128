defmodule LEB128 do
  @moduledoc """
  Module for encoding and decoding LEB128 (Little Endian Base 128) encoded numbers.
  Reference: https://en.wikipedia.org/wiki/LEB128#Unsigned_LEB128

  ## Usage

  ```elixir
  iex> LEB128.encode_unsigned(624_485)
  <<0xE5, 0x8E, 0x26>>

  iex> LEB128.decode_unsigned!(<<0xE5, 0x8E, 0x26>>)
  {624_485, ""}

  iex> LEB128.decode_unsigned!(<<0xE5, 0x8E>>)
  {:error, :incomplete}
  ```
  """

  @doc """
  Decodes an unsigned LEB128 encoded number. Crashes if the input is invalid.

  Example:
  ```elixir
  iex> LEB128.decode_unsigned!(<<0xE5, 0x8E, 0x26>>)
  {624_485, ""}
  ```
  """
  def decode_unsigned!(bits) do
    {:ok, num, rest} = decode_unsigned(bits)
    {num, rest}
  end

  @doc """
  Decodes an unsigned LEB128 encoded number.

  Example:
  ```elixir
  iex> LEB128.decode_unsigned(<<0xE5, 0x8E, 0x26>>)
  {:ok, 624_485, ""}
  iex> LEB128.decode_unsigned(<<0xE5, 0x8E>>)
  {:error, :incomplete}
  ```
  """
  def decode_unsigned(bits) do
    case do_decode_leb128(bits, []) do
      {:error, reason} ->
        {:error, reason}

      {value, rest} ->
        <<num::unsigned-size(bit_size(value))>> = value
        {:ok, num, rest}
    end
  end

  @doc """
  Decodes a signed LEB128 encoded number. Crashes if the input is invalid.

  Example:
  ```elixir
  iex> LEB128.decode_signed!(<<0xC0, 0xBB, 0x78>>)
  {-123_456, ""}
  ```
  """
  def decode_signed!(bits) do
    {:ok, num, rest} = decode_signed(bits)
    {num, rest}
  end

  @doc """
  Decodes a signed LEB128 encoded number.

  Example:
  ```elixir
  iex> LEB128.decode_signed(<<0xC0, 0xBB, 0x78>>)
  {:ok, -123_456, ""}
  iex> LEB128.decode_signed(<<0xE5, 0x8E>>)
  {:error, :incomplete}
  ```
  """
  def decode_signed(bits) do
    case do_decode_leb128(bits, []) do
      {:error, reason} ->
        {:error, reason}

      {value, rest} ->
        <<num::signed-size(bit_size(value))>> = value
        {:ok, num, rest}
    end
  end

  defp do_decode_leb128(<<0::size(1), payload::size(7), rest::binary>>, acc) do
    bits =
      (acc ++ [payload])
      |> Enum.reverse()
      |> Enum.reduce("", fn x, acc -> <<acc::bitstring, x::size(7)>> end)

    {bits, rest}
  end

  defp do_decode_leb128(<<1::size(1), payload::size(7), rest::binary>>, acc) do
    acc = acc ++ [payload]
    do_decode_leb128(rest, acc)
  end

  defp do_decode_leb128(<<>>, _acc) do
    {:error, :incomplete}
  end

  @doc """
  Encodes an unsigned LEB128 encoded number.

  Example:
  ```elixir
  iex> LEB128.encode_unsigned(624_485)
  <<0xE5, 0x8E, 0x26>>
  ```
  """
  def encode_unsigned(number) do
    bits = for <<bit::size(1) <- :binary.encode_unsigned(number)>>, do: bit

    bits =
      case Enum.drop_while(bits, &(&1 == 0)) do
        [] -> [0]
        rest -> rest
      end

    do_leb128(bits, false)
  end

  @doc """
  Encodes a signed LEB128 encoded number.

  Example:
  ```elixir
  iex> LEB128.encode_signed(-123_456)
  <<0xC0, 0xBB, 0x78>>
  ```
  """
  def encode_signed(number) do
    is_signed = number < 0
    number = abs(number)
    bits = for <<bit::size(1) <- :binary.encode_unsigned(number)>>, do: bit
    bits = [0 | Enum.drop_while(bits, &(&1 == 0))]
    do_leb128(bits, is_signed)
  end

  defp do_leb128(bits, is_signed) do
    len = length(bits)
    missing = ceil(len / 7) * 7 - len
    padded = List.duplicate(0, missing) ++ bits

    padded =
      if is_signed do
        len = length(padded)
        padded = Enum.map(padded, fn bit -> if bit == 0, do: 1, else: 0 end)

        <<num::unsigned-size(len)>> =
          Enum.reduce(padded, "", fn bit, acc -> <<acc::bitstring, bit::size(1)>> end)

        for <<(bit::size(1) <- <<num + 1::unsigned-size(len)>>)>>, do: bit
      else
        padded
      end

    Enum.chunk_every(padded, 7)
    |> Enum.with_index()
    |> Enum.map(fn {chunk, index} ->
      marker = if index == 0, do: <<0::size(1)>>, else: <<1::size(1)>>
      [marker | Enum.map(chunk, &<<&1::size(1)>>)]
    end)
    |> Enum.reverse()
    |> List.flatten()
    |> Enum.reduce("", fn bit, acc -> <<acc::bitstring, bit::bitstring>> end)
  end
end
