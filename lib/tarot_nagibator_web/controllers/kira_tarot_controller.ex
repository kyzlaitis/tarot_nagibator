defmodule TarotNagibatorWeb.KiraTarotController do
  use TarotNagibatorWeb, :controller

  alias Telegex

  def webhook(_conn, params) do
    IO.puts(inspect(params))
  end

  def set_webhook(_conn, _params) do
    Telegex.set_webhook(System.get_env("TG_KIRA_WEB_HOOK"))
  end
end
