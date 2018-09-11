defmodule API.Router.Emoji do
  use Plug.Router
  use Plug.ErrorHandler

  plug(
    Plug.Parsers,
    parsers: [:urlencoded, :json],
    pass: ["text/*"],
    json_decoder: Poison
  )

  plug(:match)
  plug(:dispatch)

  # Root path
  get "/" do
    send_resp(conn, 200, "Emoji root, nothing here!")
  end
  
  get "/search/" do
    %Plug.Conn{params: %{"query" => search_text}} = conn
    emojis = Emoji.search(search_text)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{emojis: emojis}, pretty: true))
  end

  get _ do
    send_resp(conn, 404, "Not found users!")
  end

  @doc """
  Handle uknown errors
  """
  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Unknown error")
  end
end
