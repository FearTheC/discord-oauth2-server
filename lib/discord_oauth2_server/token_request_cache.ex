defmodule DiscordOauth2Server.TokenRequestCache do
  use GenServer


  def lookup_referer(state) do
    case GenServer.call(__MODULE__, {:get, state}) do
      [] -> {:not_found}
      [{state, result}] -> {:found, result, state}
    end
  end

  def lookup_referer!(state) do
    case lookup_referer state do
      {:found, result} -> result
      {:not_found} -> raise "Request token not found"
    end
  end

  def set_state_referer(state, referer) do
    GenServer.call(__MODULE__, {:set, state, referer})
  end

  def clear_state(state) do
    GenServer.cast(__MODULE__, {:clear_state, state})
  end

  def start_link _opts \\ [] do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init _ do
    :ets.new(:referer_lookup, [:set, :public, :named_table, read_concurrency: true])
    {:ok, nil}
  end

  def handle_call({:set, state, referer}, _pid, _) do
    true = :ets.insert(:referer_lookup, {state, referer})
    {:reply, state, referer}
  end

  def handle_call({:get, state}, _pid, _) do
    result = :ets.lookup(:referer_lookup, state)
    {:reply, result, state}
  end

  def handle_cast({:clear_state, state}, _state) do
    :ets.delete(:referer_lookup, state)
    {:noreply, state}
  end

end
