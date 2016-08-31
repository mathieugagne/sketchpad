defmodule Sketchpad.Counter do

  ## USAGE

  # iex(1)> alias Sketchpad.Counter 
  # Sketchpad.Counter
  # iex(2)> {:ok, pid} = Counter.start_link
  # {:ok, #PID<0.225.0>}
  # iex(3)> Counter.inc(pid)
  # :inc
  # iex(4)> Counter.inc(pid)
  # :inc
  # iex(5)> Counter.inc(pid)
  # :inc
  # iex(6)> Counter.inc(pid)
  # :inc
  # iex(7)> Counter.val(pid)
  # 4
  # iex(8)> Counter.dec(pid)
  # :dec
  # iex(9)> Counter.val(pid)
  # 3

  ## Client

  def inc(pid), do: send(pid, :inc)
  def dec(pid), do: send(pid, :dec)
  def val(pid, timeout \\ 5000) do
    # Guaranteed unique value
    ref = make_ref()
    send(pid, {:val, self(), ref})
    receive do
      {:val, ^ref, val} -> val
    after timeout -> exit(:timeout)
    end
  end
  
  ## Server

  def start_link(initial_count \\ 0) do
    {:ok, spawn_link(fn -> listen(initial_count) end)}
  end

  # Recursive allows us to keep state of count
  defp listen(count) do
    receive do
      :inc -> listen(count + 1)
      :dec -> listen(count - 1)
      {:val, sender, ref} ->
        send(sender, {:val, ref, count})
        listen(count)
    end
  end

end