Firebase = require("firebase")
moment = require("moment")
ref = new Firebase(process.env.fire_url)
ref.auth(process.env.firebase_secret)

heartbeat = ->
  time = moment(time).format('MMMM Do YYYY, h:mm:ss a')
  ref.child("heartbeat/facebook-events").set time, ->
    console.log "Tick, #{time}"
    
setInterval heartbeat, 30*1000

