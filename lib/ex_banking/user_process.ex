defmodule ExBanking.UserProcess do
  @moduledoc false
  use GenServer, restart: :transient

  alias ExBanking.UserRegistry

  def start_link(user), do: GenServer.start_link(__MODULE__, user, name: process_name(user))

  def init(_user), do: {:ok, %{}}

  def call(user, mfa, opts \\ %{}) do
    with {:ok, pid} <- get_pid(user),
         :ok <- check_force_or_request_count_limit(pid, opts) do
      GenServer.call(pid, {:call, mfa}, :infinity)
    end
  end

  def handle_call({:call, {func, args}}, _from, state) do
    {reply, state} = func.(state, args)

    {:reply, reply, state}
  end

  defp process_name(user), do: {:via, Registry, {UserRegistry, user_name(user)}}

  defp user_name(user), do: "user:#{user}"

  defp get_pid(user) do
    case Registry.lookup(UserRegistry, user_name(user)) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :user_does_not_exist}
    end
  end

  @request_count_limit 10
  defp check_force_or_request_count_limit(pid, opts) do
    force = Map.get(opts, :force, false)
    request_count_limit = Map.get(opts, :request_count_limit, @request_count_limit)

    if force or Process.info(pid)[:message_queue_len] < request_count_limit do
      :ok
    else
      {:error, :too_many_requests_to_user}
    end
  end
end
