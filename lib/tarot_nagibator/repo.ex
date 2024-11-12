defmodule TarotNagibator.Repo do
  use Ecto.Repo,
    otp_app: :tarot_nagibator,
    adapter: Ecto.Adapters.Postgres
end
