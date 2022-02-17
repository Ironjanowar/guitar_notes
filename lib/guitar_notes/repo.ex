defmodule GuitarNotes.Repo do
  use Ecto.Repo,
    otp_app: :guitar_notes,
    adapter: Ecto.Adapters.Postgres
end
