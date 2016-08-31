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

    this.bind()
  },

  bind() {
    this.pad.on("stroke", data => {
      this.padChannel.push("stroke", data)
        // .receive("ok", ..) # Could add callbacks based on PadChannel#handle_in/3
    })
    this.padChannel.on("stroke", ({user_id, stroke}) => {
      this.pad.putStroke(user_id, stroke, {color: "#000"})
    })
  }
}

App.init(window.userId, window.userToken)