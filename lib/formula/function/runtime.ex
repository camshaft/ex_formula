defmodule Formula.Function.Runtime do
  alias Decimal, as: D
  alias Formula.Error

  def exec(name, arguments, opts) do
    case Enum.find(arguments, &Formula.Error.error?/1) do
      nil ->
        call(name, arguments, opts)
      error ->
        error
    end
  end

  defp call(:+, [a], _opts) do
    D.plus(D.new(a))
  end
  defp call(:+, [a, b], _opts) do
    D.add(D.new(a), D.new(b))
  end
  defp call(:-, [a], _opts) do
    D.minus(D.new(a))
  end
  defp call(:-, [a, b], _opts) do
    D.sub(D.new(a), D.new(b))
  end
  defp call(:*, [a, b], _opts) do
    D.mult(D.new(a), D.new(b))
  end
  defp call(:/, [_, 0], _) do
    %Formula.Error.DivideByZero{}
  end
  defp call(:/, [a, b], _opts) do
    D.div(D.new(a), D.new(b))
  end
  defp call(:^, [a, b], _opts) do
    pow(D.new(a), D.new(b))
  end
  defp call(:%, [a], _opts) do
    D.div(D.new(a), D.new(100))
  end
  defp call(:=, [a, b], _opts) do
    a == b
  end
  defp call(:<>, [a, b], _opts) do
    a != b
  end
  defp call(:>, [a, b], _opts) do
    D.cmp(D.new(a), D.new(b)) == :gt
  end
  defp call(:<, [a, b], _opts) do
    D.cmp(D.new(a), D.new(b)) == :lt
  end
  defp call(:>=, [a, b], _opts) do
    D.cmp(D.new(a), D.new(b)) != :lt
  end
  defp call(:<=, [a, b], _opts) do
    D.cmp(D.new(a), D.new(b)) != :gt
  end
  defp call(:&, [a, b], _opts) do
    to_string([a, b])
  end

  ## logical
  defp call("AND", arguments, _opts) do
    Enum.all?(arguments)
  end
  defp call("FALSE", [], _opts) do
    false
  end
  defp call("IF", [test, then], _opts) do
    if test, do: then
  end
  defp call("IF", [test, then, otherwise], _opts) do
    if test, do: then, else: otherwise
  end
  defp call("IFS", [], _opts) do
    nil
  end
  defp call("IFS", [otherwise], _opts) do
    otherwise
  end
  defp call("IFS", [value, then | rest], opts) do
    if value, do: then, else: call("IFS", rest, opts)
  end
  defp call("IFERROR", [value, then], _opts) do
    if Error.error?(value), do: then
  end
  defp call("IFERROR", [value, then, otherwise], _opts) do
    if Error.error?(value), do: then, else: otherwise
  end
  defp call("NOT", [value], _opts) do
    !value
  end
  defp call("OR", arguments, _opts) do
    Enum.any?(arguments)
  end
  defp call("TRUE", [], _opts) do
    true
  end
  defp call("XOR", arguments, _opts) do
    Enum.count(arguments, &(&1)) == 1
  end
  defp call("SWITCH", [value | rest], _opts) do
    switch(value, rest)
  end

  defp call(name, arguments, _opts) do
    throw {:undefined_function, {name, length(arguments)}}
  end

  defp switch(_value, []) do
    nil
  end
  defp switch(_value, [otherwise]) do
    otherwise
  end
  defp switch(value, [test, then | rest]) do
    if value == test, do: then, else: switch(value, rest)
  end

  # TODO make it so we don't lose precision here
  defp pow(a, b) do
    a = D.to_float(a)
    b = D.to_float(b)
    :math.pow(a, b)
    |> D.new()
  end
end
