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
          amount :: number(),
          currency()
        ) ::
          {:ok, new_balance :: number()}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency)
      when is_binary(user) and
             is_number(amount) and amount >= 0 and
             is_binary(currency) do
    UserProcess.call(user, {&UserLogic.deposit/2, %{amount: amount, currency: currency}})
  end

  def deposit(_user, _amount, _currency), do: {:error, :wrong_arguments}

  @doc ~S"""
  Withdraw

  ## Examples

    iex> ExBanking.create_user("User With Money")
    iex> ExBanking.deposit("User With Money", 200, "RUB")
    iex> ExBanking.withdraw("User With Money", 100.01, "RUB")
    {:ok, 99.99}


    iex> ExBanking.create_user("User Rub")
    iex> ExBanking.withdraw("User Rub", 100, "RUB")
    {:error, :not_enough_money}

    iex> ExBanking.withdraw(1, 1, 1)
    {:error, :wrong_arguments}

    iex> ExBanking.withdraw("Another", 1, "RUB")
    {:error, :user_does_not_exist}

  """
  @spec withdraw(
          user(),
          amount :: number(),
          currency()
        ) ::
          {:ok, new_balance :: number()}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}
  def withdraw(user, amount, currency)
      when is_binary(user) and
             is_number(amount) and amount > 0 and
             is_binary(currency) do
    UserProcess.call(user, {&UserLogic.withdraw/2, %{amount: amount, currency: currency}})
  end

  def withdraw(_user, _amount, _currency), do: {:error, :wrong_arguments}

  @doc ~S"""
  Get balance

  ## Examples

    iex> ExBanking.create_user("Ivanoff")
    iex> ExBanking.deposit("Ivanoff", 99.99, "RUB")
    iex> ExBanking.get_balance("Ivanoff", "RUB")
    {:ok, 99.99}

    iex> ExBanking.create_user("Petroff")
    iex> ExBanking.get_balance("Petroff", "RUB")
    {:ok, 0.0}

    iex> ExBanking.get_balance("Sidoroff", "USD")
    {:error, :user_does_not_exist}

    iex> ExBanking.get_balance(1, 1)
    {:error, :wrong_arguments}

  """
  @spec get_balance(
          user(),
          currency()
        ) ::
          {:ok, balance :: number()}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) when is_binary(user) and is_binary(currency) do
    UserProcess.call(user, {&UserLogic.get_balance/2, %{currency: currency}})
  end

  def get_balance(_user, _currency), do: {:error, :wrong_arguments}

  @doc ~S"""
  Send

  ## Examples

    iex> ExBanking.create_user("Sender")
    iex> ExBanking.deposit("Sender", 100, "USD")
    iex> ExBanking.create_user("Reicever")
    iex> ExBanking.send("Sender", "Reicever", 50, "USD")
    {:ok, 50.0, 50.0}

    iex> ExBanking.send(1, 1, 1, 1)
    {:error, :wrong_arguments}

    iex> ExBanking.send("Sender1", "Reicever1", 50, "USD")
    {:error, :sender_does_not_exist}

    iex> ExBanking.create_user("Sender2")
    iex> ExBanking.send("Sender2", "Reicever2", 50, "USD")
    {:error, :not_enough_money}

    iex> ExBanking.create_user("Sender3")
    iex> ExBanking.deposit("Sender3", 100, "USD")
    iex> ExBanking.send("Sender3", "Reicever3", 50, "USD")
    {:error, :receiver_does_not_exist}

  """
  @spec send(
          from_user :: user(),
          to_user :: user(),
          amount :: number,
          currency()
        ) ::
          {:ok, from_user_balance :: number(), to_user_balance :: number()}
          | {:error,
             :wrong_arguments
             | :not_enough_money
             | :sender_does_not_exist
             | :receiver_does_not_exist
             | :too_many_requests_to_sender
             | :too_many_requests_to_receiver}
  def send(from_user, to_user, amount, currency)
      when is_binary(from_user) and
             is_binary(to_user) and
             is_number(amount) and amount > 0 and
             is_binary(currency) do
    with {:sender, {:ok, from_user_balance}} <-
           {:sender,
            UserProcess.call(
              from_user,
              {&UserLogic.withdraw/2, %{amount: amount, currency: currency}}
            )},
         {:receiver, {:ok, to_user_balance}} <-
           {:receiver,
            UserProcess.call(
              to_user,
              {&UserLogic.deposit/2, %{amount: amount, currency: currency}}
            )} do
      {:ok, from_user_balance, to_user_balance}
    else
      {:sender, {:error, :user_does_not_exist}} ->
        {:error, :sender_does_not_exist}

      {:sender, {:error, :not_enough_money}} ->
        {:error, :not_enough_money}

      {:sender, {:error, :too_many_requests_to_user}} ->
        {:error, :too_many_requests_to_sender}

      {:receiver, {:error, :user_does_not_exist}} ->
        UserProcess.call(
          from_user,
          {&UserLogic.deposit/2, %{amount: amount, currency: currency}},
          %{force: true}
        )

        {:error, :receiver_does_not_exist}

      {:receiver, {:error, :too_many_requests_to_user}} ->
        UserProcess.call(
          from_user,
          {&UserLogic.deposit/2, %{amount: amount, currency: currency}},
          %{force: true}
        )

        {:error, :too_many_requests_to_receiver}
    end
  end

  def send(_from_user, _to_user, _amount, _currency), do: {:error, :wrong_arguments}
end
