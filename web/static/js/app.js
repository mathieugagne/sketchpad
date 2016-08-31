import "phoenix_html"
import {Socket, Presence} from "phoenix"
import {Sketchpad, sanitize} from "./sketchpad"

let socket = new Socket("/socket", {
  params: {token: window.userToken}
})
socket.connect()