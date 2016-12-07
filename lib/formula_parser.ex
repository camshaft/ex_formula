defmodule FormulaParser do
  def parse(string) do
    {:ok, parse!(string)}
  rescue
    e ->
      {:error, e}
  end

  def parse!(string) do
    string
    |> FormulaParser.Lexer.tokenize!()
    |> :formula_parser_parser.parse()
    |> case do
      {:ok, value} ->
        value
      {:error, {_line, module, message}} ->
        raise __MODULE__.Error, message: to_string(module.format_error(message))
    end
  end
end
