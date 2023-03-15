# Edemo


This is a small parser built in elixir using erlangs bitstring and pattern
matching design. It uses recursion to transform a binary string into a set of
datastructures.

My intention was to use erlangs tail call elimination recursion which is a unique
feature of the erlang virtual machine. Most languaues do not do tail-call elimination
and as such recursive functions tend to be limited by stack size.



## Execution

mix escript.build
./edemo



