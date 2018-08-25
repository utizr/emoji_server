defmodule Emoji.Worker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def get_status() do
    GenServer.call(__MODULE__, {:get_status})
  end

  def init(_) do
    IO.puts("#{__MODULE__} initializing")
    initialize_emojis()
    {:ok, %{status: :initialized}}
  end

  def initialize_emojis() do
    Emoji.Fetcher.start()
    Emoji.Extractor.extract_data_from_file()
  end

  def handle_call({:get_status}, _from, state) do
    {:reply, state.status, state}
  end
end
