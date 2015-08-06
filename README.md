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

### Agent

Agents are one of the abstractions that come with elixir and OTP.
Their purpose is to store state that might be accessed by more than one process or by a single process and different points in time.
They are a simple server implementation that has an API to set and retrieve state.

The agent server is a `GenServer` that uses the `Agent.Server` [module](https://github.com/elixir-lang/elixir/blob/master/lib/elixir/lib/agent/server.ex)
Most messages passed to the Agent are calls this means that the call is blocking until the state value is returned.

Agents are created and modified with functions and not values. These functions are evaluated in the Agent server process

agent start function executed immediately and not re-executed for subsequent calls
```elixir
{:ok, agent} = Agent.start fn -> :calendar.local_time() end
```

##### Considerations
*Copied from the Agent source*

Note that agents still provide a segregation between the
client and server APIs, as seen in GenServers. In particular,
all code inside the function passed to the agent is executed
by the agent. This distinction is important because you may
want to avoid expensive operations inside the agent, as it will
effectively block the agent until the request is fulfilled.
Consider these two examples:
```elixir
# Compute in the agent/server
def get_something(agent) do
  Agent.get(agent, fn state -> do_something_expensive(state) end)
end
# Compute in the agent/client
def get_something(agent) do
  Agent.get(agent, &(&1)) |> do_something_expensive()
end
```
The first function blocks the agent. The second function copies
all the state to the client and then executes the operation in the
client. The difference is whether the data is large enough to require
processing in the server, at least initially, or small enough to be
sent to the client cheaply.

### GenServer

Stands for generic server and is a behaviour module for implementing the server of a client-server relation.
The GenServer process runs a module, the module should start with `use GenServer`.
Desired behaviour is implemented by adding the `handle_call/3` and `handle_cast/2` methods.

The server callbacks are described separate to the module documentation, [here](http://elixir-lang.org/docs/stable/elixir/#!GenServer.html).

##### Callbacks

calls are synchronous and should be used by default.
The fact they block is a useful back pressure mechanism.

casts are asynchronous, they also do not guarantee delivery of the message

##### monitor vs link
Links are bi-directional.
If you link two process and one of them crashes, the other side will crash too (unless it is trapping exits).
A monitor is uni-directional: only the monitoring process will receive notifications about the monitored one.

##### GenEvent
GenEvent is also a server implementation and can store state.

Broadcasts messages to one or more handlers synchronously or asynchronously.
`sync_notify/2` and `notify/2` are analogous to `call/2` and `cast/2` in GenServer and using `sync_notify/2` is generally recommended for the backpressure.
