defmodule Edemo do

  def example do
    """
    1234  pretty=きれいな, mem=23234M, cpu=2131, cat=\"hat\", boat=goat
    1235  noisy=うるさい, mem=23234M, cpu=2131, cat=\"hat\", boat=goat
    1236  spacious=ひろい, mem=23234M, cpu=2131, cat=\"hat\", boat=goat
    1257  salmon=しゃけ, mem=23234M, cpu=2131, cat=\"hat\", boat=goat
    1258  bean=まめ, mem=23234M, cpu=2131, cat=\"hat\", boat=goat
    1259  near=ちかい, mem=23234M, cpu=2131, cat=\"hat\", boat=goat
    1260  fish=さかな, mem=23234M, cpu=2131, cat=\"hat\", boat=goat
    """
  end

  def parse_fn(<<>>, _) do
    {:ok, :end}
  end

  # parsing number header
  def parse_fn(<<char, rest::bitstring>>, false) when char >= 48 and char <= 57,
    do: {:ok, :timestamp, [char - 48], rest}

  # parsing number characters as part of keypair
  def parse_fn(<<char, rest::bitstring>>, true) when char >= 48 and char <= 57,
    do: {:ok, :keypair, <<char>>, rest}

  def parse_fn(<<char, rest::bitstring>>, true) when
  (char != 32 or char != 44) and (char >= 65 or char == 61 or char == 34),
    do: {:ok, :keypair, <<char>>, rest}

  def parse_fn(<<char, rest::bitstring>>, _) when char == 32,
    do: {:ok, :skip, rest}

  def parse_fn(<<char, rest::bitstring>>, _) when char == 10,
    do: {:ok, :next, rest}

  def parse_fn(<<char,rest::bitstring>>, true) when char == 44,
    do: {:ok, :end_keypair, rest }


  def parse_fn(_, _), do: {:error, :invalid_input}

  def parsed_default() do
    %{
      timestamp: [],
      attr: %{},
      key_buffer: "",
      ts_set: false
    }
  end

  def parse_wrap(input) do
    parse_wrap(
      input,
      parsed_default(),
      []
    )
  end

  def parse_wrap(input, parsed, set) do
    case parse_fn(input, parsed.ts_set) do
      {:ok, :timestamp, charlist, rest } ->
        parse_wrap(rest,
          Map.merge(parsed,%{timestamp: parsed.timestamp ++ charlist}),
          set)
      {:ok, :keypair, charlist, rest } ->
        parse_wrap(rest,
          Map.merge(parsed,%{key_buffer: parsed.key_buffer <> charlist }),
          set)
      {:ok, :end_keypair, rest} ->
        finished_parsed = process_keypair_buffer(parsed)
        parse_wrap(rest,
          finished_parsed,
          set
        )
      {:ok, :skip , rest} ->
        timestamp_set = length(parsed.timestamp) != 0
        assume_timestamp_set_parsed = Map.merge(parsed,%{ts_set: timestamp_set})
        parse_wrap(rest, assume_timestamp_set_parsed, set )
      {:ok, :next, rest} ->
        finished_parsed = process_keypair_buffer(parsed)
        parse_wrap(rest, parsed_default(), set ++ [finished_parsed])
      {:ok, :end} ->
        set
      {:error, issue } ->
        [issue, input, parsed, set]
    end
  end

  def process_keypair_buffer(parsed) do
    key_buffer = parsed.key_buffer
    case String.length(key_buffer) do
       0 ->
        parsed
       _ ->
        [key, value] = String.split(key_buffer, "=")
        clear_parsed = Map.merge(parsed,%{key_buffer: ""})
        Map.merge(clear_parsed,
          %{attr:
            Map.merge(clear_parsed.attr, %{key => value})
          })
    end
  end


  def main(args) do
    IO.puts example()
    IO.inspect args, label: "args"
    # test case :timestamp
    IO.inspect parse_wrap("1226653\n")
    # testcase timestamp and keyvalue pair with unicode
    IO.inspect parse_wrap("1233333 a子狐=b,\n")
    # testcase timestamp and 2 keyvalue pair with unicode
    IO.inspect parse_wrap("1233333 a子狐=b, bbb=aaa\n")
    # testcase timestamp and 3 keyvalue pair with unicode and second timestamp
    IO.inspect parse_wrap(" 1233333 a子狐=b, bbb=aaa, ccc=12312M\n12321\n")
   # IO.inspect parse_wrap("子狐=\"b\",")

    IO.inspect parse_wrap(example())
    :world
    options = [switches: [file: :string],aliases: [f: :file]]
    {opts,_,_}= OptionParser.parse(args, options)
    IO.inspect opts, label: "Command Line Arguments"
  end
end
