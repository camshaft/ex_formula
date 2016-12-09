defmodule Formula.Lexer do
  def tokenize!(binary) do
    binary
    |> tokenize(nil, [], [])
    |> :lists.reverse()
  end

  defp tokenize("", nil, [], tokens) do
    tokens
  end
  defp tokenize("", nil, buffer, tokens) do
    [symbol(buffer) | tokens]
  end
  for {type, char} <- [string: "\"", path: "'"] do
    defp tokenize(unquote(char <> char) <> rest, unquote(type), buffer, tokens) do
      tokenize(rest, unquote(type), [buffer, unquote(char)], tokens)
    end
    defp tokenize(unquote(char) <> rest, unquote(type), buffer, tokens) do
      tokenize(rest, nil, [], [{unquote(type), 1, to_string(buffer)} | tokens])
    end
  end
  defp tokenize("]" <> rest, :range, buffer, tokens) do
    tokenize(rest, nil, [], [{:range, 1, to_string(buffer)} | tokens])
  end
  for type <- ["NULL!", "DIV/0!", "VALUE!", "REF!", "NAME?", "NUM!", "N/A"] do
    defp tokenize(unquote(type) <> rest, :error, [], tokens) do
      tokenize(rest, nil, [], [{:error, 1, unquote(type)} | tokens])
    end
  end
  defp tokenize(rest, :error, _, _) do
    throw {:invalid_error, "#" <> rest}
  end
  # TODO scientific notation +-
  defp tokenize("\"" <> rest, nil, buffer, tokens) do
    assert_empty(buffer, "\"")
    tokenize(rest, :string, [], tokens)
  end
  defp tokenize("'" <> rest, nil, buffer, tokens) do
    assert_empty(buffer, "'")
    tokenize(rest, :path, [], tokens)
  end
  defp tokenize("[" <> rest, nil, buffer, tokens) do
    assert_empty(buffer, "[")
    tokenize(rest, :range, [], tokens)
  end
  defp tokenize("#" <> rest, nil, buffer, tokens) do
    assert_empty(buffer, "#")
    tokenize(rest, :error, [], tokens)
  end
  for char <- [" ", "\n", "\t"] do
    defp tokenize(unquote(char) <> rest, nil, buffer, tokens) do
      tokenize(rest, nil, [], maybe_flush(buffer, tokens))
    end
  end
  ops = [">=", "<=", "<>", "+", "-", "*", "/", "^", "&", "=", ">", "<", "(", ")", ",", "%", "{", "}", ";"]
  for char <- ops do
    defp tokenize(unquote(char) <> rest, nil, buffer, tokens) do
      tokenize(rest, nil, [], [{unquote(String.to_atom(char)), 1} | maybe_flush(buffer, tokens)])
    end
  end
  defp tokenize(<<char :: binary-size(1), rest :: binary>>, state, buffer, token) do
    tokenize(rest, state, [buffer, char], token)
  end

  defp assert_empty([], _) do
    :ok
  end
  defp assert_empty(buffer, char) do
    throw {:not_empty, to_string(buffer), char}
  end

  defp maybe_flush([], tokens) do
    tokens
  end
  defp maybe_flush(buffer, tokens) do
    [symbol(buffer) | tokens]
  end

  defp symbol(buffer) do
    case to_string(buffer) do
      "TRUE" ->
        {:string, 1, true}
      "FALSE" ->
        {:string, 1, false}
      buffer ->
        case Decimal.parse(buffer) do
          {:ok, v} ->
            {:string, 1, v}
          :error ->
            {:symbol, 1, buffer}
        end
    end
  end
end
