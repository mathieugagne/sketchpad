defmodule Sketchpad.UserSocket do
  use Phoenix.Socket

  ## Channels
  # channel "room:*", Sketchpad.RoomChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket,
    check_origin: false
    # Check that the socket was initiated from this whitelist of domains
    # check_origin: ["//example.com"]

  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.

  import Phoenix.Token, only: [verify: 4]
  def connect(%{"token" => token}, socket) do
    case verify(socket, "user token salt", token, max_age: 1209600) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}
      {:error, _invalid} ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Sketchpad.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
