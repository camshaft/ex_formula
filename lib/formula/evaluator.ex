defmodule Formula.Evaluator do
  defmodule Pending do
    defstruct []
  end

  def evaluate(sheet, opts) do
    sheet
    |> Enum.reduce(sheet, fn({key, formula}, acc) ->
      acc = Map.put(acc, key, %Formula.Evaluator.Pending{})
      {value, acc} = Formula.Evaluable.evaluate(formula, acc, opts)
      Map.put(acc, key, value)
    end)
  end
end

defprotocol Formula.Evaluable do
  @fallback_to_any true
  def evaluate(obj, sheet, opts)
end

defimpl Formula.Evaluable, for: Any do
  def evaluate(value, sheet, _opts) do
    {value, sheet}
  end
end

defimpl Formula.Evaluable, for: List do
  def evaluate(value, sheet, opts) do
    Enum.map_reduce(value, sheet, fn(formula, acc) ->
      @protocol.evaluate(formula, acc, opts)
    end)
  end
end

defimpl Formula.Evaluable, for: Formula.Evaluator.Pending do
  def evaluate(_, sheet, _opts) do
    {%Formula.Error.Ref{}, sheet}
  end
end

defimpl Formula.Evaluable, for: Formula.Symbol do
  def evaluate(%{name: name}, sheet, opts) do
    case Map.fetch(sheet, name) do
      {:ok, formula} ->
        sheet = Map.put(sheet, name, %Formula.Evaluator.Pending{})
        {value, sheet} = @protocol.evaluate(formula, sheet, opts)
        {value, Map.put(sheet, name, value)}
    end
  end
end

defimpl Formula.Evaluable, for: Formula.Function do
  def evaluate(%{name: name, arguments: arguments}, sheet, opts) do
    arity = length(arguments)
    {arguments, sheet} = @protocol.evaluate(arguments, sheet, opts)
    case get_in(opts, [:functions, {name, arity}]) do
      nil ->
        @for.Runtime.exec(name, arguments, sheet, opts)
      fun ->
        fun.(arguments, sheet, opts)
    end
  end
end
