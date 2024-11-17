defmodule TarotNagibator.EnvLoaderTest do
  use ExUnit.Case, async: true
  alias TarotNagibator.EnvLoader.EnvLoader

  @file_content """
    KEY1="VALUE1"
    KEY2 = "VALUE2"
    KEY3=VALUE3
  """

  setup do
    {:ok, temp_file} = create_temp_file(@file_content)
    %{temp_file: temp_file}
  end


  test "load/1 sets .env file properly", %{temp_file: temp_file} do
    EnvLoader.load(temp_file)

    assert System.get_env("KEY1") == "VALUE1"
    assert System.get_env("KEY2") == "VALUE2"
    assert System.get_env("KEY3") == "VALUE3"

  after
    System.delete_env("KEY1")
    System.delete_env("KEY2")
    System.delete_env("KEY3")
    File.rm!(temp_file)
  end

  defp create_temp_file(content) do
    temp_file = Path.join(System.tmp_dir!(), "env_test_1.env" )

    case File.write(temp_file, content) do
      :ok -> {:ok, temp_file}
      :error -> {:error, temp_file}
    end
  end
end
