defmodule TarotNagibator.Services.OpenAi do

  alias HTTPoison
  @open_ai_url "https://api.openai.com/v1/chat/completions"
  @bearer System.get_env("OPEN_AI_API_KEY")
  @model "gpt-4o-mini"

  def get_tarot() do
    headers = [
      {"Authorization", "Bearer #{@bearer}"},
      {"Content-Type", "application/json"},
      {"Accept", "application/json"}
    ]

    body = endode_body()

    case HTTPoison.post(@open_ai_url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        IO.puts("success")
      {:ok, %HTTPoison.Response{status_code: 400}} ->
        IO.puts("error")
    end
  end

  def endode_body do
    %{
      "model" => @model,
      "messages" => [
        %{"role" => "user", "content" => "Hi, give me a very short response as it is a test for my application"}
      ]
    } |> Jason.encode!()
  end

end
