defmodule Sketchpad.PadChannel do
  use Sketchpad.Web, :channel

  # /1 is the topic
  def join("pad:" <> pad_id, _params, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    {:noreply, socket}
  end
end