defmodule ExBanking.UserLogicTest do
  use ExUnit.Case, async: true
  alias ExBanking.{UserLogic, Money}

  test "deposit/2" do
    wallet = %{}
    money_usd = Money.new(9.99)
    money_rub = Money.new(7)

    {balance, new_wallet} = UserLogic.deposit(wallet, %{amount: 9.99, currency: "USD"})
    assert {{:ok, 9.99}, %{"USD" => money_usd}} == {balance, new_wallet}
    {balance, new_wallet} = UserLogic.deposit(new_wallet, %{amount: 7, currency: "RUB"})
    assert {{:ok, 7.0}, %{"RUB" => money_rub, "USD" => money_usd}} == {balance, new_wallet}
  end

  test "withdraw/2" do
    wallet = %{"USD" => Money.new(10_000)}

    assert {{:ok, 4999.99}, %{"USD" => Money.new(4999.99)}} ==
             UserLogic.withdraw(wallet, %{amount: 5000.01, currency: "USD"})

    assert {{:error, :not_enough_money}, %{"USD" => Money.new(10_000)}} ==
             UserLogic.withdraw(wallet, %{amount: 5000.01, currency: "RUB"})
  end

  test "get_balance/2" do
    wallet = %{"USD" => Money.new(1_000)}

    assert {{:ok, 1000.0}, wallet} == UserLogic.get_balance(wallet, %{currency: "USD"})
    assert {{:ok, 0.0}, wallet} == UserLogic.get_balance(wallet, %{currency: "RUB"})
  end
end
