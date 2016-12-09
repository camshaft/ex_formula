defmodule Test.Formula do
  use ExUnit.Case
  import Formula
  alias Decimal, as: D

  test "bmi" do
    %{"weight" => "99.7903", "height" => "1.8796"}
    |> Map.merge(%{"bmi" => "=weight / (height ^ 2)"})
    |> compile!()
    |> evaluate!()
    |> assert_cell("bmi", fn(bmi) ->
      28 == bmi |> D.to_float() |> trunc()
    end)
  end

  test "IF" do
    %{"A1" => "1", "A2" => "=IF(A1 = 1, TRUE)"}
    |> compile!()
    |> evaluate!()
    |> assert_cell("A2", true)
  end

  defp assert_cell(sheet, cell, value) when is_function(value) do
    assert value.(sheet[cell])
  end
  defp assert_cell(sheet, cell, value) do
    assert sheet[cell] == value
  end
end
