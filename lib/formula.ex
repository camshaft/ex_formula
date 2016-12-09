defmodule Formula do
  def compile!(sheet) do
    sheet
    |> Stream.map(fn({key, value}) ->
      {key, parse!(value)}
    end)
    |> Enum.into(%{})
  end

  def evaluate!(sheet, opts \\ %{}) do
    __MODULE__.Evaluator.evaluate(sheet, opts)
  end

  def parse(string) do
    {:ok, parse!(string)}
  rescue
    e ->
      {:error, e}
  end

  def parse!("") do
    {:ok, nil}
  end
  def parse!(string) do
    string
    |> __MODULE__.Lexer.tokenize!()
    |> :formula_parser.parse()
    |> case do
      {:ok, value} ->
        value
      {:error, {_line, module, message}} ->
        raise __MODULE__.Error, message: to_string(module.format_error(message))
    end
  end
end
