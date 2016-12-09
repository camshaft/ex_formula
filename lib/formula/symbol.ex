defmodule Formula.Symbol do
  defstruct [:name]

  def new({:symbol, _, name}) do
    new(name)
  end
  def new(name) do
    %__MODULE__{name: name}
  end
end
