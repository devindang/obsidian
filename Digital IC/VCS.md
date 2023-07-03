## Flow

Translation -> Compile -> Link -> Runtime

![[VCS_flow.png]]

`-debug`, `-debug_all`, `-debug_access` or `debug_access` option is required in compile time.
`-ucli` is used in runtime.

```verilog
vcs sourcefile [compile_time_option]
./simv [run_time_option]
```

> **Note**: You can use the -ucli option at runtime even if you have not used some form of the -debug_access option during compilation, but in this case only the `run` and `quit` UCLI commands are supported.

