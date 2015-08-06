Mix and OTP
===========

Exploring Mix and OTP by following example laid out on the elixir lang [getting started pages](http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html)

### Introducing

**OTP (Open Telecom Platform)** is a set of libraries that ships with Erlang.
Erlang developers use OTP to build robust, fault-tolerant applications.
In this chapter we will explore how many aspects from OTP integrate with Elixir, including supervision trees, event managers and more;

**Mix** is a build tool that ships with Elixir that provides tasks for creating, compiling, testing your application, managing its dependencies and much more;

**ExUnit** is a test-unit based framework that ships with Elixir;

### Starting a mix project

Start new project with mix by executing the following command.

```
$ mix new kv --module KV
```

##### Structure

Creates a new directory `kv` which contains the application. **Remember** to change into directory after making new project.

There is initial structure is a valid project and can be compiled.
To compile execute `mix compile`.
To start an iex session in the project execute `iex -S mix`.

##### Testing

By convention there is a test file named `<filename>_test.exs` for each file in the lib directory.
Files containing tests have the `.exs` extension not `.ex` as the do not need to be compiled before running the tests.
Test modules are named `<MODULE>Test`.

To run all the tests execute `mix test`.
Exunit supports running and individual test, by providing the filename and line number where the test starts.

```
$ mix test test/<filename>_test.exs:<line number>
```

##### Environment
Mix supports the concepts of environments and understand three out of the box.


- `:dev` - the one in which Mix tasks (like compile) run by default
- `:test` - used by mix test
- `:prod` - the one you will use to put your project in production

> Note: If you add dependencies to your project, they will not inherit your project's environment, but instead run with their :prod environment settings!

To set the environment inside mix define a `MIX_ENV` environmental variable
```
$ MIX_ENV=staging iex -S mix
```

The current environment can be accessed by using the `Mix.env/0` function which returns the environment as an atom.
```elixir
Mix.env
# :staging
```
