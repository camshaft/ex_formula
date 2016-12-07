defmodule FormulaParser.Error do
  defexception [:message]

  errors = %{
    "NULL!" => Null,
    "DIV/0!" => DivideByZero,
    "VALUE!" => Value,
    "REF!" => Ref,
    "NAME?" => Name,
    "NUM!" => Num,
    "N/A" => NA
  }

  def new({:error, _, name}) do
    new(name)
  end
  for {symbol, name} <- errors do
    name = Module.concat(__MODULE__, name)
    defmodule name do
      defexception [:message]

      def message(%{message: nil}) do
        unquote("Encountered error #{symbol}")
      end
      def message(%{message: message}) do
        message
      end
    end

    def new(unquote(symbol)) do
      %unquote(name){}
    end
  end
end
