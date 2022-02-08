defmodule ExBanking.UserProcessTest do
  use ExUnit.Case, async: true
  alias ExBanking.{UserSupervisor, UserProcess}

  test "user does not exist" do
    assert {:error, :user_does_not_exist} = UserProcess.call("some", :no_matter)
  end

  test "too many requests to user" do
    func = fn state, _ ->
      Process.sleep(500)
      {:ok, state}
    end

    assert :ok == UserSupervisor.create_user("user")
    # in test case very hard make overloading
    # thats why we use very small limit
    opts = %{request_count_limit: 1}

    tasks =
      for i <- 1..10 do
        Process.sleep(200)
        Task.async(fn -> UserProcess.call("user", {func, i}, opts) end)
      end
      |> Enum.map(&Task.await/1)

    assert Enum.any?(tasks, &(&1 == :ok))
    assert Enum.any?(tasks, &(&1 == {:error, :too_many_requests_to_user}))
  end
end
