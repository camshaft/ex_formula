defmodule Test.Formula do
  use ExUnit.Case
  import Formula
  alias Decimal, as: D

  test "bmi" do
    sheet =
      %{"weight" => "99.7903", "height" => "1.8796"}
      |> Map.merge(%{"bmi" => "weight / (height ^ 2)"})
      |> compile!()
      |> evaluate!()

    assert 28 = sheet["bmi"] |> D.to_float() |> trunc()
  end
end
