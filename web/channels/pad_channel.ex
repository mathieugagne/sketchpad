defmodule Sketchpad.PadChannel do
  use Sketchpad.Web, :channel
  alias Sketchpad.{Pad, Presence, Endpoint}

  def broadcast_stroke(pad_id, from, user_id, stroke) do
    Endpoint.broadcast_from!(from, "pad:#{pad_id}", "stroke", %{
      user_id: user_id,
      stroke: stroke
    })
  end

  # /1 is the topic
  def join("pad:" <> pad_id, _params, socket) do
    send(self(), :after_join)

    {:ok, pad} = Pad.find(pad_id)
    data = Pad.render(pad)

    socket =
      socket
      |> assign(:pad_id, pad_id)
      |> assign(:pad, pad)

    {:ok, %{data: data}, socket}
  end

  def handle_info(:after_join, socket) do
    %{user_id: user_id} = socket.assigns
    {:ok, _ref} = Presence.track(socket, user_id, %{device: "browser"})
    push(socket, "presence_state", Presence.list(socket))

    {:noreply, socket}
  end

  # We should pattern match on data to make sure we have
  #  a valid data structure so we're not able to send
  #  whatever we want through the socket
  def handle_in("stroke", data, socket) do
    %{user_id: user_id, pad: pad, pad_id: pad_id} = socket.assigns
    Pad.put_stroke(pad, pad_id, user_id, data)

    {:reply, :ok, socket}
  end

  def handle_in("clear", _params, socket) do
    broadcast!(socket, "clear", %{})
    {:reply, :ok, socket}
  end
end