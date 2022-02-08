defmodule ExBanking.UserSupervisorTest do
  use ExUnit.Case, async: true
  alias ExBanking.UserSupervisor

  test "create_user/1" do
    assert :ok == UserSupervisor.create_user("new_user")
    assert {:error, :user_already_exists} == UserSupervisor.create_user("new_user")
  end
end
