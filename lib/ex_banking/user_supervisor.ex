defmodule ExBanking.UserSupervisor do
  @doc """
  User Supervisor
  """
  use DynamicSupervisor

  alias ExBanking.UserProcess

  def start_link(arg), do: DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)

  @impl true
  def init(_arg), do: DynamicSupervisor.init(strategy: :one_for_one)

  @doc """
  Create user
  """
  @spec create_user(ExBanking.user()) :: :ok | {:error, :user_already_exists}
  def create_user(user) do
    case DynamicSupervisor.start_child(__MODULE__, {UserProcess, user}) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> {:error, :user_already_exists}
    end
  end
end
