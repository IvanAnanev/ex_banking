defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking`.
  """

  alias ExBanking.{UserSupervisor}

  @type user() :: String.t()
  @type currency() :: String.t()

  @doc """
  Create user

  ## Examples

    iex> ExBanking.create_user("wallet")
    :ok

    iex> ExBanking.create_user(10)
    {:error, :wrong_arguments}
  """
  @spec create_user(user()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) when is_binary(user), do: UserSupervisor.create_user(user)
  def create_user(_user), do: {:error, :wrong_arguments}
end
