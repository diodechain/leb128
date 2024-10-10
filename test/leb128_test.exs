defmodule LEB128Test do
  use ExUnit.Case
  doctest LEB128

  test "edge cases" do
    match_unsigned(0, <<0>>)
    match_unsigned(127, <<127>>)
    match_unsigned(128, <<128, 1>>)

    match_signed(0, <<0x00>>)
    match_signed(127, <<255, 0>>)
    match_signed(128, <<128, 1>>)
    match_signed(-1, <<127>>)
    match_signed(-63, <<65>>)
    match_signed(-64, <<192, 127>>)
    match_signed(-127, <<129, 127>>)
    match_signed(-128, <<128, 127>>)

    assert LEB128.decode_unsigned(<<0x80>>) == {:error, :incomplete}
    assert LEB128.decode_signed(<<0x80>>) == {:error, :incomplete}
  end

  defp match_unsigned(decoded, encoded) do
    assert LEB128.encode_unsigned(decoded) == encoded
    assert LEB128.decode_unsigned!(encoded) == {decoded, ""}
  end

  defp match_signed(decoded, encoded) do
    assert LEB128.encode_signed(decoded) == encoded
    assert LEB128.decode_signed!(encoded) == {decoded, ""}
  end
end
