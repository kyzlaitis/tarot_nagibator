defmodule TarotNagibator.Services.Telegram.PollingHandler do
  use Telegex.Polling.GenHandler

  def on_boot() do

    {:ok, true} = Telegex.delete_webhook()

    %Telegex.Polling.Config{}
  end


  def on_update(update) do
    IO.puts(inspect(update))

    :ok
  end
end
