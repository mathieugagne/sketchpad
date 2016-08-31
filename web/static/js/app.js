import "phoenix_html"
import {Socket, Presence} from "phoenix"
import {Sketchpad, sanitize} from "./sketchpad"

let App = {
  init(userId, token){ if(!token){ return }
  let socket = new Socket("/socket", {
    params: {token: token}
  })

  this.sketchpadContainer = document.getElementById("sketchpad")
  this.pad = new Sketchpad(this.sketchpadContainer, userId)

  socket.connect()

  this.padChannel = socket.channel("pad:lobby")
  this.padChannel.join()
    .receive("ok", response => console.log("joined!", response))
    .receive("error", response => console.log("join failed!", response))
  }
}

App.init(window.userId, window.userToken)