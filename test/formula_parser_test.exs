defmodule Test.FormulaParser do
  use ExUnit.Case
  import FormulaParser
  alias FormulaParser.{Function,Symbol}

  test "simple addition" do
    assert %Function{name: :+, arguments: [1, 1]} = parse!("""
    1 + 1
    """)
  end

  test "symbol subtraction" do
    assert %Function{name: :-, arguments: [%Symbol{name: "A2"}, %Symbol{name: "B4"}]} =
      parse!("""
      A2 - B4
      """)
  end

  test "function call" do
    assert %Function{name: "FOO", arguments: [1,2,3,4,5]} = parse!("""
    FOO(1,    2, 3,  4,5)
    """)
  end
end
