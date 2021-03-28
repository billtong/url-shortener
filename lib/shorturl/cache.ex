defmodule Shorturl.Cache do
  use GenServer

  def start_link(init_args) do
    GenServer.start_link(__MODULE__, init_args, name: init_args[:server_name])
  end

  @impl GenServer
  def init(init_args) do
    :ets.new(init_args[:ets_name], [:set, :public, :named_table])
    schedule_cache_check(init_args[:ttl_check_interval])
    state = Enum.into(init_args, %{})
    {:ok, state}
  end

  def state(server) do
    GenServer.call(server, {:state})
  end

  def get(server, key) do
    GenServer.call(server, {:get, key})
  end

  def delete(server, key) do
    GenServer.cast(server, {:delete, key})
  end

  def put(server, key, value) do
    GenServer.cast(server, {:put, key, value})
  end

  @impl GenServer
  def handle_call({:state}, _from, state), do: {:reply, state, state}

  @impl GenServer
  def handle_call({:get, key}, _from, %{ets_name: ets_name} = state) do
    reply =
    case :ets.lookup(ets_name, key) do
      [] -> nil
      [{_key, value, _exp}] -> value
    end
    {:reply, reply, state}
  end

  @impl GenServer
  def handle_cast({:delete, key}, %{ets_name: ets_name} = state) do
    :ets.delete(ets_name, key)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:put, key, value}, %{ets_name: ets_name, ttl: ttl, max_size: max_size} = state) do
    info = :ets.info(ets_name)
    cond do
      info[:size] < max_size ->
        expiration = :os.system_time(:millisecond) + ttl
        :ets.insert(ets_name, {key, value, expiration})
      true -> true
    end
    {:noreply, state}
  end

  defp schedule_cache_check(ttl_interval) do
    Process.send_after(self(), :check_purge, ttl_interval)
  end

  @impl GenServer
  def handle_info(:check_purge, %{ets_name: ets_name, ttl_check_interval: ttl_interval} = state) do
    :ets.tab2list(ets_name)
    |> Enum.each(fn {key, _value, expiration} ->
      cond do
        expiration < :os.system_time(:millisecond) ->
          :ets.delete(ets_name, key)
        true -> true
      end
    end)
    schedule_cache_check(ttl_interval)
    {:noreply, state}
  end

end
