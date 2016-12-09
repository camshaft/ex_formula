defmodule Formula.Range do
  defstruct [:value]

  def new({:range, _, value}) do
    new(value)
  end
  def new(value) do
    %__MODULE__{value: value}
  end
end
