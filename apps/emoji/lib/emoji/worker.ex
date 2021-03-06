defmodule Emoji.Worker do

  @moduledoc """
  Reponsible for triggering the fetcher and extractor every day to refresh the emoji list.
  """
  
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def get_status() do
    GenServer.call(__MODULE__, {:get_status})
  end

  def init(_) do
    Logger.info("#{__MODULE__} initializing")
    initialize_emojis()
    {:ok, %{status: :initialized}}
  end

  def initialize_emojis() do
    extract_from_local_copy()
    update_emojis()
  end

  defp extract_from_local_copy() do
    Emoji.Extractor.extract_data_from_file()
  end

  defp update_emojis() do
    case Emoji.Fetcher.start() do
      :data_uptodate ->
        :ok
      :data_refreshed ->
        extract_from_local_copy()
      :error ->
        Logger.error "Unknown error occured at updating emojis."
        :error
    end
    schedule(:update_emojis)
  end

  def handle_call({:get_status}, _from, state) do
    {:reply, state.status, state}
  end

  # SCHEDULER ================

  def schedule(:update_emojis) do
    Logger.info "Scheduling emoji update.."
    Process.send_after(self(), :update_emojis, hour_millis() * 24)
  end

  def minute_millis(), do: 1000 * 60

  def hour_millis(), do: 1000 * 60 * 60

  def day_millis(), do: hour_millis() * 24

  def handle_info(:update_emojis, state) do
    Logger.info "Starting scheduled update of emojis.."
    update_emojis()
    {:noreply, state}
  end

end
