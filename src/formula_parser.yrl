Nonterminals

expression

function function_arguments
prefix infix postfix
array array_items array_item_row
.

Terminals
symbol
string path range error
'>=' '<=' '<>' '+' '-' '*' '/' '^' '&' '=' '>' '<'
'(' ')' ',' '%'
'{' '}' ';'
.

Rootsymbol expression.

Left 150 '=' '<>'.
Left 160 '<' '>' '<=' '>='.
Right 200 '&'.
Left 210 '+' '-'.
Left 220 '*' '/'.
Nonassoc 300 '^'.
Nonassoc 310 '%'.

expression -> symbol : 'Elixir.Formula.Symbol':new('$1').
expression -> string : element(3, '$1').
expression -> path : 'Elixir.Formula.Path':new('$1').
expression -> range : 'Elixir.Formula.Range':new('$1').
expression -> error : 'Elixir.Formula.Error':new('$1').
expression -> prefix : '$1'.
expression -> infix : '$1'.
expression -> postfix : '$1'.
expression -> array : '$1'.
expression -> '(' expression ')' : '$2'.
expression -> function : '$1'.

function -> symbol '(' ')' : 'Elixir.Formula.Function':new('$1', []).
function -> symbol '(' function_arguments ')' : 'Elixir.Formula.Function':new('$1', '$3').

function_arguments -> expression : ['$1'].
function_arguments -> expression ',' function_arguments : ['$1' | '$3'].

prefix -> '+' expression : 'Elixir.Formula.Function':new('+', ['$1']).
prefix -> '-' expression : 'Elixir.Formula.Function':new('-', ['$1']).

infix -> expression '+' expression : 'Elixir.Formula.Function':new('+', ['$1', '$3']).
infix -> expression '-' expression : 'Elixir.Formula.Function':new('-', ['$1', '$3']).
infix -> expression '*' expression : 'Elixir.Formula.Function':new('*', ['$1', '$3']).
infix -> expression '/' expression : 'Elixir.Formula.Function':new('/', ['$1', '$3']).
infix -> expression '^' expression : 'Elixir.Formula.Function':new('^', ['$1', '$3']).
infix -> expression '<' expression : 'Elixir.Formula.Function':new('>', ['$1', '$3']).
infix -> expression '>' expression : 'Elixir.Formula.Function':new('>', ['$1', '$3']).
infix -> expression '=' expression : 'Elixir.Formula.Function':new('=', ['$1', '$3']).
infix -> expression '>=' expression : 'Elixir.Formula.Function':new('>=', ['$1', '$3']).
infix -> expression '<=' expression : 'Elixir.Formula.Function':new('<=', ['$1', '$3']).
infix -> expression '<>' expression : 'Elixir.Formula.Function':new('<>', ['$1', '$3']).
infix -> expression '&' expression : 'Elixir.Formula.Function':new('&', ['$1', '$3']).

postfix -> expression '%' : 'Elixir.Formula.Function':new('%', ['$1']).

array -> '{' '}' : [].
array -> '{' array_items '}' : '$2'.

array_items -> array_item_row : ['$1'].
array_items -> array_item_row ';' array_items : ['$1' | '$3'].

array_item_row -> expression : ['$1'].
array_item_row -> expression ',' array_item_row : ['$1' | '$3'].

Erlang code.
