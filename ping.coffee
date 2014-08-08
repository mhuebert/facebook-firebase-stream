rest = require("restler")
moment = require("moment")

ping = ->
  console.log "Tick, #{moment().format('MMMM Do YYYY, h:mm:ss a')}"
  r = rest.get process.env.image_server_url

  r.on "success", (data, response) -> 
    console.log "Image server up"

  r.on "fail", (data, response) -> console.log data, "Image server not responding"
  r.on "error", (err, response) -> console.log err, "Image server not responding"
setInterval ping, 180*1000
ping()