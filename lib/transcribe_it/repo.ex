defmodule TranscribeIt.Repo do
  use Ecto.Repo,
    otp_app: :transcribe_it,
    adapter: Ecto.Adapters.Postgres
end
