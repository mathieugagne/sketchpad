defmodule Sketchpad.PadChannel do
  use Sketchpad.Web, :channel
  alias Sketchpad.{Pad, Presence, Endpoint}

  def broadcast_clear(pad_id) do
    Endpoint.broadcast!("pad:#{pad_id}", "clear", %{})
  end

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

    socket =
      socket
      |> assign(:pad_id, pad_id)
      |> assign(:pad, pad)

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    %{pad: pad, user_id: user_id} = socket.assigns
    {:ok, _ref} = Presence.track(socket, user_id, %{device: "browser"})
    push socket, "presence_state", Presence.list(socket)

    for {id, %{strokes: strokes}} <- Pad.render(pad) do
      for stroke <- Enum.reverse(strokes) do
        push socket, "stroke", %{user_id: id, stroke: stroke}
      end
    end

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
    :ok = Pad.clear(socket.assigns.pad, socket.assigns.pad_id)
    {:reply, :ok, socket}
  end
end