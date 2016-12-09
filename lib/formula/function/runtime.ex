defmodule Formula.Function.Runtime do
  alias Decimal, as: D

  def exec(name, arguments, sheet, opts) do
    case Enum.find(arguments, &Formula.Error.error?/1) do
      nil ->
        call(name, arguments, sheet, opts)
      error ->
        {error, sheet}
    end
  end

  defp call(:+, [a], sheet, _opts) do
    {D.plus(D.new(a)), sheet}
  end
  defp call(:+, [a, b], sheet, _opts) do
    {D.add(D.new(a), D.new(b)), sheet}
  end
  defp call(:-, [a], sheet, _opts) do
    {D.minus(D.new(a)), sheet}
  end
  defp call(:-, [a, b], sheet, _opts) do
    {D.sub(D.new(a), D.new(b)), sheet}
  end
  defp call(:*, [a, b], sheet, _opts) do
    {D.mult(D.new(a), D.new(b)), sheet}
  end
  defp call(:/, [_, 0], _, _) do
    %Formula.Error.DivideByZero{}
  end
  defp call(:/, [a, b], sheet, _opts) do
    {D.div(D.new(a), D.new(b)), sheet}
  end
  defp call(:^, [a, b], sheet, _opts) do
    {pow(D.new(a), D.new(b)), sheet}
  end
  defp call(:%, [a], sheet, _opts) do
    {D.div(D.new(a), D.new(100)), sheet}
  end
  defp call(:=, [a, b], sheet, _opts) do
    {a == b, sheet}
  end
  defp call(:<>, [a, b], sheet, _opts) do
    {a != b, sheet}
  end
  defp call(:>, [a, b], sheet, _opts) do
    {D.cmp(D.new(a), D.new(b)) == :gt, sheet}
  end
  defp call(:<, [a, b], sheet, _opts) do
    {D.cmp(D.new(a), D.new(b)) == :lt, sheet}
  end
  defp call(:>=, [a, b], sheet, _opts) do
    {D.cmp(D.new(a), D.new(b)) != :lt, sheet}
  end
  defp call(:<=, [a, b], sheet, _opts) do
    {D.cmp(D.new(a), D.new(b)) != :gt, sheet}
  end
  defp call(:&, [a, b], sheet, _opts) do
    {to_string([a, b]), sheet}
  end

  defp call(name, arguments, _sheet, _opts) do
    throw {:undefined_function, {name, length(arguments)}}
  end

  # TODO make it so we don't lose precision here
  defp pow(a, b) do
    a = D.to_float(a)
    b = D.to_float(b)
    :math.pow(a, b)
    |> D.new()
  end
end
