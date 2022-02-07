defmodule ExBanking.Money do
  @moduledoc """
  Money, money, money, money...
  """
  @type t :: %__MODULE__{
          value: integer()
        }

  defstruct value: 0

  @doc ~S"""
  Make new money

  ## Examples
    iex> ExBanking.Money.new(100)
    #Money<100.00>

    iex> ExBanking.Money.new(0)
    #Money<0.00>

    iex> ExBanking.Money.new(0.01)
    #Money<0.01>

    iex> ExBanking.Money.new(0.001)
    #Money<0.00>

    iex> ExBanking.Money.new(0.009)
    #Money<0.00>

    iex> ExBanking.Money.new(10_000)
    #Money<10 000.00>

    iex> ExBanking.Money.new("some")
    {:error, :not_number}

    iex> ExBanking.Money.new(-1)
    {:error, :not_positive}
  """
  @spec new(any) :: ExBanking.Money.t() | {:error, :not_number | :not_positive}
  def new(number) when is_number(number) and number >= 0 do
    parse(number)
  end

  def new(number) when is_number(number), do: {:error, :not_positive}
  def new(_number), do: {:error, :not_number}

  @doc ~S"""
  Convert to string

  ## Examples

    iex> money = ExBanking.Money.new(1_000_000_000)
    iex> ExBanking.Money.to_string(money)
    "1 000 000 000.00"
  """
  @spec to_string(ExBanking.Money.t()) :: binary()
  def to_string(%__MODULE__{value: value}) do
    raw =
      value
      |> Integer.digits()
      |> Enum.map(&Integer.to_charlist/1)

    raw_length = length(raw)

    list =
      cond do
        raw_length == 1 ->
          ['0', '.', '0'] ++ raw

        raw_length == 2 ->
          ['0', '.'] ++ raw

        true ->
          {tail, base} =
            raw
            |> Enum.reverse()
            |> Enum.split(2)

          base =
            base
            |> Enum.chunk_every(3)
            |> Enum.intersperse(' ')
            |> List.flatten()

          Enum.reverse(base) ++ ['.'] ++ Enum.reverse(tail)
      end

    IO.iodata_to_binary(list)
  end

  @doc ~S"""
  Convert to float

  ## Examples

    iex> money = ExBanking.Money.new(1_000_000_000)
    iex> ExBanking.Money.to_float(money)
    1000000000.0

    iex> money = ExBanking.Money.new(0.01)
    iex> ExBanking.Money.to_float(money)
    0.01
  """
  @spec to_float(__MODULE__.t()) :: float()
  def to_float(%__MODULE__{value: value}), do: value / 100

  @doc ~S"""
  Increase money

  ## Examples

    iex> money_1 = ExBanking.Money.new(1_000)
    iex> money_2 = ExBanking.Money.new(999.99)
    iex> ExBanking.Money.increase(money_1, money_2)
    #Money<1 999.99>
  """
  @spec increase(__MODULE__.t(), __MODULE__.t()) :: __MODULE__.t()
  def increase(%__MODULE__{value: value_1}, %__MODULE__{value: value_2}) do
    %__MODULE__{value: value_1 + value_2}
  end

  @doc ~S"""
  Decrease money

  ## Examples

    iex> money_1 = ExBanking.Money.new(1_000)
    iex> money_2 = ExBanking.Money.new(999.99)
    iex> ExBanking.Money.decrease(money_1, money_2)
    #Money<0.01>

    iex> money_1 = ExBanking.Money.new(1_000)
    iex> money_2 = ExBanking.Money.new(1000.00)
    iex> ExBanking.Money.decrease(money_1, money_2)
    #Money<0.00>

    iex> money_1 = ExBanking.Money.new(999.99)
    iex> money_2 = ExBanking.Money.new(1_000)
    iex> ExBanking.Money.decrease(money_1, money_2)
    {:error, :not_enough}
  """
  @spec decrease(__MODULE__.t(), __MODULE__.t()) :: __MODULE__.t() | {:error, :not_enough}
  def decrease(%__MODULE__{value: value_1}, %__MODULE__{value: value_2}) do
    if value_1 >= value_2 do
      %__MODULE__{value: value_1 - value_2}
    else
      {:error, :not_enough}
    end
  end

  defp parse(number) when is_integer(number), do: %__MODULE__{value: number * 100}
  defp parse(number) when is_float(number), do: %__MODULE__{value: trunc(number * 100)}
end

defimpl Inspect, for: ExBanking.Money do
  def inspect(money, _opts) do
    "#Money<" <> ExBanking.Money.to_string(money) <> ">"
  end
end

defimpl String.Chars, for: ExBanking.Money do
  def to_string(money) do
    ExBanking.Money.to_string(money)
  end
end
