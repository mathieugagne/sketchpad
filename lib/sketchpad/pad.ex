defmodule Sketchpad.Pad do
  use GenServer

  ## Client

  def find(pad_id) do
    case :global.whereis_name("pad:#{pad_id}") do
      pid when is_pid(pid) -> {:ok, pid}
      :undefined -> {:error, :undefined}
    end
  end

  def put_stroke(pid, pad_id, user_id, stroke) do
    :ok = GenServer.call(pid, {:stroke, user_id, stroke})
    Sketchpad.PadChannel.broadcast_stroke(
      pad_id,
      self(),
      user_id,
      stroke)
  end

  def clear(pid) do
    GenServer.call(pid, :clear)
  end

  def render(pid) do
    GenServer.call(pid, :render)
  end

  ## Server

  def start_link(topic) do
    GenServer.start_link(__MODULE__, topic, name: {:global, topic})
  end

  def init("pad:" <> pad_id) do
    {:ok, %{users: %{}, pad_id: pad_id}}
  end

  def handle_call(:clear, _from, state) do
    {:reply, :ok, %{state | users: %{}}}
  end

  def handle_call(:render, _from, state) do
    {:reply, state.users, state}
  end

  def handle_call({:stroke, user_id, stroke}, _from, state) do
    {:reply, :ok, do_put_stroke(state, user_id, stroke)}
  end

  defp do_put_stroke(%{users: users} = state, user_id, stroke) do
    users = Map.put_new(users, user_id, %{id: user_id, strokes: []})
    users = update_in(users, [user_id, :strokes], fn strokes ->
      [stroke | strokes]
    end)

    %{state | users: users}
  end
  
end