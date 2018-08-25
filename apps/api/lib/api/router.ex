defmodule API.Router do
  use Plug.Router
  plug(Plug.Logger)

  if Mix.env() == :dev do
    use Plug.Debugger
  end
  plug CORSPlug
  plug Plug.Head
  use Plug.ErrorHandler
  plug(:match)
  plug(:dispatch)


  forward("/emoji", to: API.Router.Emoji)

  get _ do
    send_resp(conn, 404, "Not found!")
  end

  @doc """
  Handle uknown errors
  """
  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Unknown error")
  end
end
