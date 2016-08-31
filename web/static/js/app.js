import "phoenix_html"
import {Socket, Presence} from "phoenix"
import {Sketchpad, sanitize} from "./sketchpad"

let App = {
  init(userId, token){ if(!token){ return }
    let socket = new Socket("/socket", {
      params: {token: token}
    })

    this.sketchpadContainer = document.getElementById("sketchpad")
    this.clearButton = document.getElementById("clear-button")
    this.exportButton = document.getElementById("export-button")
    this.usersContainer = document.getElementById("users")
    this.presences = {}
    this.pad = new Sketchpad(this.sketchpadContainer, userId)

    socket.connect()

    this.padChannel = socket.channel("pad:lobby")
    this.padChannel.join()

    this.bind()
  },

  bind() {
    this.clearButton.addEventListener("click", e => {
      e.preventDefault()
      this.padChannel.push("clear")
    })
    this.padChannel.on("clear", () => this.pad.clear())

    this.exportButton.addEventListener("click", e => {
      e.preventDefault()
      window.open(this.pad.getImageURL())
    })

    this.pad.on("stroke", data => {
      this.padChannel.push("stroke", data)
        // .receive("ok", ..) # Could add callbacks based on PadChannel#handle_in/3
    })
    this.padChannel.on("stroke", ({user_id, stroke}) => {
      this.pad.putStroke(user_id, stroke, {color: "#000"})
    })

    this.padChannel.on("presence_state", state => {
      this.presences = Presence.syncState(this.presences, state)
      this.renderUsers()
    })

    this.padChannel.on("presence_diff", diff => {
      this.presences = Presence.syncDiff(this.presences, diff,
        this.onPresenceJoin.bind(this),
        this.onPresenceLeave.bind(this)
      )
      this.renderUsers()
    })
  },

  onPresenceJoin(id, currentPresence, newPresence) {
    if (!currentPresence) {
      console.log(`${id} has joined for the first time`)
    } else {
      console.log(`${id} has joined before from elsewhere`)
    }
  },

  onPresenceLeave(id, currentPresence, leftPresence) {
    if (currentPresence.metas.length === 0) {
      console.log(`${id} has left for good`)
    } else {
      console.log(`${id} has left`)
    }
  },

  renderUsers() {
    let listBy = (id, {metas: [first, ...rest]}) => {
      first.id = id
      first.count = rest.length + 1
      return first
    }
    let users = Presence.list(this.presences, listBy)
    this.usersContainer.innerHTML = users.map(user => {
      return `${sanitize(user.id)} (${user.count})<br />`
    }).join("")
  }
}

App.init(window.userId, window.userToken)