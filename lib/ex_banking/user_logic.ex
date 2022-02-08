defmodule ExBanking.UserLogic do
  @moduledoc """
  User logic
  """
  alias ExBanking.Money
  @type wallet :: map()

  @doc """
  Deposit
  """
  @spec deposit(wallet(), %{amount: number(), currency: ExBanking.currency()}) ::
          {{:ok, float()}, wallet()}
  def deposit(wallet, %{amount: amount, currency: currency}) do
    money_in_wallet = Map.get(wallet, currency, Money.new(0))
    added_money = Money.new(amount)
    new_money = Money.increase(money_in_wallet, added_money)
    new_wallet = Map.put(wallet, currency, new_money)
    {{:ok, Money.to_float(new_money)}, new_wallet}
  end
end
