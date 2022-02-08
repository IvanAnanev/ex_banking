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
end
