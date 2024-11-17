defmodule TarotNagibator.EnvLoader.EnvLoader do

  def load(file_path) do
    file_path
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "=", trim: true))
      |> Enum.each(fn [key, value] ->
          clean_value = String.trim(value, " ") |> String.replace("\"", "")
          clean_key = String.trim(key, " ")
          System.put_env(clean_key, clean_value)
      end)
  end

end
