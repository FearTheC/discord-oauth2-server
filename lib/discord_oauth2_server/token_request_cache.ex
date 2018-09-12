defmodule DiscordOauth2Server.TokenRequestCache do
  use GenServer


  def lookup_referer(state) do
    case GenServer.call(__MODULE__, {:get, state}) do
      [] -> {:not_found}
      [{state, result}] -> {:found, result}
    end
  end

  def lookup_referer!(state) do
    case lookup_referer state do
      {:found, result} -> result
      {:not_found} -> raise TokenRequestCacheError, message: "Not Found"
    end
  end

  def set_state_referer(state, referer) do
    GenServer.call(__MODULE__, {:set, state, referer})
  end

  def start_link opts \\ [] do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init _ do
    :ets.new(:referer_lookup, [:set, :public, :named_table, read_concurrency: true])
    {:ok, nil}
  end

  def handle_call({:set, state, referer}, pid, _) do
    true = :ets.insert(:referer_lookup, {state, referer})
    {:reply, state, referer}
  end

  def handle_call({:get, state}, pid, _) do
    result = :ets.lookup(:referer_lookup, state)
    {:reply, result, state}
  end

end
