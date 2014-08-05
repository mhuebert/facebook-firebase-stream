express = require("express")
Firebase = require("firebase")
hash = require('object-hash')
url = require('url')
bodyParser = require('body-parser')
{denormalize} = require("./utils")

app = express()
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: true)

# For process.env variables with a REPL:
# env = require('node-env-file')
# env('./.env')

Firebase = new Firebase(process.env.fire_url)
Firebase.auth(process.env.firebase_secret)

# REQUIRED - respond to Facebook's verification GET request
app.get "/webhooks/page-feed", (req, res) ->
  query = url.parse(req.url, true).query
  if query["hub.verify_token"] != process.env["verify_token"]
    console.log "Invalid verify_token from Facebook"
    res.send "Incorrect token", 400
    return
  res.send query["hub.challenge"]

# Receive updates from Facebook
app.post "/webhooks/page-feed", (req, res) ->
  for item in denormalize(req.body)
    console.log item
    # Only save new posts (not comments, or changes to old posts)
    if item.verb == "add" and item.hasOwnProperty("post_id")
      # Items are sorted by key. We want descending order by time,
      # along with a hash of the item itself, so that we never add the same item twice.
      time = 10000000000 - parseInt item["__time"]
      Firebase.child("stream/#{time+hash.MD5(item)}").update(item)
  res.status(200).send "Thanks"
  


# A series of useless pages required for Facebook's app approval process
app.get "user-support", (req, res) ->
  res.status(200).send "USER SUPPORT<br><br>This is an internal tool created by and for a team of one. Therefore, if you are a user, and you have problems, you should fix them, because you made this."

app.get "privacy-policy", (req, res) ->
  res.status(200).send "PRIVACY POLICY<br><br>This is an internal tool that will only be used with our own Facebook page. We promise not to violate our own privacy by doing bad things with our own data."

app.all "/", (req, res) ->
  res.status(200).send "<h1>Stats:</h1><p>TBC</p>"

app.listen(process.env.PORT || 3000)

