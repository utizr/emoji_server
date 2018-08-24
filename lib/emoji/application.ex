defmodule Emoji.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Emoji.Worker, nil},
    ]

    opts = [strategy: :one_for_one, name: Emoji.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
