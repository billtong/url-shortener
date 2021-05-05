defmodule Shorturl.CacheTest do
  use ExUnit.Case, async: true
  alias Shorturl.Cache

  @cache_init_args [
    server_name: :test_cache_server,
    ets_name: :test_cache_ets,
    ttl: 100, # the expire time is 100 ms
    ttl_check_interval: 10, # check every 10 ms
    max_size: 3
  ]

  @key_1 "test key 1"
  @key_2 "test key 2"
  @key_3 "test key 3"
  @key_4 "test key 4"
  @value_1 "test key value 1"
  @value_2 "test key value 2"
  @value_3 "test key value 3"
  @value_4 "test key value 4"

  setup do
    {:ok, pid} = Cache.start_link(@cache_init_args)
    {:ok, pid: pid}
  end

  test "check inital state" do
    state = :sys.get_state(@cache_init_args[:server_name])

    assert state == Enum.into(@cache_init_args, %{})
  end

  test "put key value pair in the cache" do
    assert Cache.put(@cache_init_args[:server_name], @key_1, @value_1) == :ok
    assert Cache.get(@cache_init_args[:server_name], @key_1) == @value_1
  end

  test "maixmum limit of putting new key pair in the cache" do
    [{@key_1, @value_1}, {@key_2, @value_2}, {@key_3, @value_3}]
    |> Enum.each(fn {k, v} ->
      assert Cache.put(@cache_init_args[:server_name], k, v) == :ok
      assert Cache.get(@cache_init_args[:server_name], k) == v
    end)
    assert Cache.put(@cache_init_args[:server_name], @key_4, @value_4) == :ok
    assert assert Cache.get(@cache_init_args[:server_name], @key_4) == nil
  end

  test "get value by key in the cache" do
    Cache.put(@cache_init_args[:server_name], @key_1, @value_1)
    assert Cache.get(@cache_init_args[:server_name], @key_1) == @value_1
  end

  test "get nil by invalid key in the cache" do
    assert Cache.get(@cache_init_args[:server_name], @key_1) == nil
  end

  test "delete key value pair in the cache" do
    Cache.put(@cache_init_args[:server_name], @key_1, @value_1)
    assert Cache.get(@cache_init_args[:server_name], @key_1) == @value_1
    assert Cache.delete(@cache_init_args[:server_name], @key_1) == :ok
    assert assert Cache.get(@cache_init_args[:server_name], @key_1) == nil
  end

  test "purge expired cache data after ttl" do
    assert Cache.put(@cache_init_args[:server_name], @key_1, @value_1) == :ok
    assert Cache.get(@cache_init_args[:server_name], @key_1) == @value_1
    Process.sleep(@cache_init_args[:ttl] + @cache_init_args[:ttl_check_interval])
    assert Cache.get(@cache_init_args[:server_name], @key_1) == nil
  end
end
