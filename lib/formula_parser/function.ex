defmodule FormulaParser.Function do
  defstruct [:name,
             :arguments]

  def new({:symbol, _, name}, arguments) do
    new(name, arguments)
  end
  def new(name, arguments) do
    %__MODULE__{name: name, arguments: arguments}
  end
end
