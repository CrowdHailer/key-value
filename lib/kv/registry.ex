defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(table, event_manager, buckets, opts \\ []) do
    # 1. start_link now expects the event manager as argument
    GenServer.start_link(__MODULE__, {table, event_manager, buckets}, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` in case a bucket exists, `:error` otherwise.
  """
  def lookup(table, name) do
    case :ets.lookup(table, name) do
      [{^name, bucket}] -> {:ok, bucket}
      [] -> :error
    end
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  ## Server callbacks

  def init({table, events, buckets}) do
    # 2. The init callback now receives the event manager.
    #    We have also changed the manager state from a tuple
    #    to a map, allowing us to add new fields in the future
    #    without needing to rewrite all callbacks.
    ets  = :ets.new(table, [:named_table, read_concurrency: true])
    refs  = HashDict.new
    {:ok, %{names: ets, refs: refs, events: events, buckets: buckets}}
  end

  def handle_call({:create, name}, _from, state) do
    case lookup(state.names, name) do
      {:ok, pid} ->
        {:reply, pid, state} # Reply with pid
        :error ->
          {:ok, pid} = KV.Bucket.Supervisor.start_bucket(state.buckets)
          ref = Process.monitor(pid)
          refs = HashDict.put(state.refs, ref, name)
          :ets.insert(state.names, {name, pid})
          GenEvent.sync_notify(state.events, {:create, name, pid})
          {:reply, pid, %{state | refs: refs}} # Reply with pid
        end
      end

      def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
        {name, refs} = HashDict.pop(state.refs, ref)
        :ets.delete(state.names, name)
        # 4. Push a notification to the event manager on exit
        GenEvent.sync_notify(state.events, {:exit, name, pid})
        {:noreply, %{state | refs: refs}}
      end

      def handle_info(_msg, state) do
        {:noreply, state}
      end
    end
