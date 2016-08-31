defmodule Sketchpad.PadChannel do
  use Sketchpad.Web, :channel

  # /1 is the topic
  def join("pad:" <> _pad_id, _params, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    {:noreply, socket}
  end

  # We should pattern match on data to make sure we have
  #  a valid data structure so we're not able to send
  #  whatever we want through the socket
  def handle_in("stroke", data, socket) do
    broadcast_from!(socket, "stroke", %{
      user_id: socket.assigns.user_id,
      stroke: data
    })
    {:reply, :ok, socket}
  end

  def handle_in("clear", _params, socket) do
    broadcast!(socket, "clear", %{})
    {:reply, :ok, socket}
  end
end