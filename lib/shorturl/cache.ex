defmodule Shorturl.Cache do
  use GenServer

  def start_link(init_args) do
    GenServer.start_link(__MODULE__, init_args, name: init_args[:server_name])
  end

  @doc """
  create a new ets set
  schedule the ttl checking
  return initial arguments as state map
  """
  @impl GenServer
  def init(init_args) do
    :ets.new(init_args[:ets_name], [:set, :public, :named_table])

    schedule_cache_check(init_args[:ttl_check_interval])
    state = Enum.into(init_args, %{})
    {:ok, state}
  end

  @doc """
  look up the ets set, and return the link struct or nil
  """
  def get(ets_name, key) do
    case :ets.lookup(ets_name, key) do
      [{_key, value, _exp}] -> value
      [] -> nil
    end
  end

  @doc """
  delete the key value pair by key
  """
  def delete(ets_name, key) do
    :ets.delete(ets_name, key)
  end

  def put(server, key, value) do
    GenServer.call(server, {:put, key, value})
  end

  @doc """
  do max size limit check first
  calculate the expiration and put {key, value, expiration} into the ets
  """
  @impl GenServer
  def handle_call({:put, key, value}, _from, %{ets_name: ets_name, ttl: ttl, max_size: max_size} = state) do
    info = :ets.info(ets_name)
    cond do
      info[:size] < max_size -> # limit the maximum cache data size
        expiration = :erlang.monotonic_time(:millisecond) + ttl
        :ets.insert(ets_name, {key, value, expiration})
      true -> true
    end
    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_call(_req, _from, state) do
    IO.puts("Error: No handle_call request matches, catch-all clause is called.")
    {:reply, nil, state}
  end

  @impl GenServer
  def handle_cast(_req, state) do
    IO.puts("Error: No handle_cast request matches, catch-all clause is called.")
    {:noreply, state}
  end

  defp schedule_cache_check(ttl_interval) do
    Process.send_after(self(), :check_purge, ttl_interval)
  end

  @doc """
  iterate all data in the ets set, delete all expired data
  schedule next purge
  """
  @impl GenServer
  def handle_info(:check_purge, %{ets_name: ets_name, ttl_check_interval: ttl_interval} = state) do
    :ets.tab2list(ets_name)
    |> Enum.each(fn {key, _value, expiration} ->
      cond do
        expiration < :erlang.monotonic_time(:millisecond) ->
          :ets.delete(ets_name, key)
        true -> true
      end
    end)
    schedule_cache_check(ttl_interval)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(_req, state) do
    IO.puts("Error: No handle_info request matches, catch-all clause is called.")
    {:noreply, state}
  end
end
