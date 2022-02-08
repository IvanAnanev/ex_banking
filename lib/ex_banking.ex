defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking`.
  """

  alias ExBanking.{UserSupervisor, UserProcess, UserLogic}

  @type user() :: String.t()
  @type currency() :: String.t()

  @doc ~S"""
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

  @doc ~S"""
  Deposit

  ## Examples
  iex> ExBanking.create_user("Usd User")
  iex> ExBanking.deposit("Usd User", 100, "USD")
  {:ok, 100.0}

  iex> ExBanking.deposit(1, 1, 1)
  {:error, :wrong_arguments}

  iex> ExBanking.deposit("Some", 1, "RUB")
  {:error, :user_does_not_exist}
  """
  @spec deposit(
          user(),
          amount :: number,
          currency()
        ) ::
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency)
      when is_binary(user) and
             is_number(amount) and amount >= 0 and
             is_binary(currency) do
    UserProcess.call(user, {&UserLogic.deposit/2, %{amount: amount, currency: currency}})
  end

  def deposit(_user, _amount, _currency), do: {:error, :wrong_arguments}
end
