Firebase = require("firebase")
moment = require("moment")
rest = require("restler")
ref = new Firebase(process.env.fire_url)
ref.auth(process.env.firebase_secret)

heartbeat = ->
  time = moment(time).format('MMMM Do YYYY, h:mm:ss a')
  ref.child("heartbeat/facebook-events").set time, ->
    console.log "Tick, #{time}"
  r = rest.get process.env.image_server_url
  
  r.on "success", (result, response) ->

  r.on "fail", (data, response) -> 
    console.log "Image server down", data
  r.on "error", (err, response) -> 
    console.log "Image server down", err

setInterval heartbeat, 20*1000
heartbeat()