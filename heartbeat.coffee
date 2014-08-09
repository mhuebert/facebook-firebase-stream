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

  r.on "fail", -> handleFail
  r.on "error", -> handleFail

handleFail = -> console.log "Image server down"

setInterval heartbeat, 20*1000
heartbeat()