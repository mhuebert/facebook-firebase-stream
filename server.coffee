Firebase = require("firebase")
hash = require('object-hash')
{extend, denormalize} = require("./utils")
express = require("express")
url = require('url')
app = express()

# For process.env variables with a REPL:
# env = require('node-env-file')
# env('./.env')

F = new Firebase(process.env.fire_url)
F.auth(process.env.firebase_secret)


app.get "/webhooks/page-feed", (req, res) ->
  query = url.parse(req.url, true).query
  if query["hub.verify_token"] != process.env["verify_token"]
    console.log "Invalid verify_token from Facebook"
    res.send "Incorrect token", 400
    return
  return query["hub.challenge"]

app.post "/webhooks/page-feed", (req, res) ->
  for item in denormalize(req.body)
    # Only save new posts (not comments, or changes to old posts)
    if item.verb == "add" and item.hasOwnProperty("post_id")
      time = 10000000000 - parseInt item["__time"]
      F.child("stream/#{time+hash.MD5(item)}").update(item)
  res.send "Thanks", 200


app.get "user-support", (req, res) ->
  res.send "USER SUPPORT<br><br>This is an internal tool created by and for a team of one. Therefore, if you are a user, and you have problems, you should fix them, because you made this.", 200


app.get "privacy-policy", (req, res) ->
  res.send "PRIVACY POLICY<br><br>This is an internal tool that will only be used with our own Facebook page. We promise not to violate our own privacy by doing bad things with our own data.", 200


app.get "/", (req, res) ->
  res.send "<h1>Stats:</h1><p>TBC</p>"


# F.child("logs").on "child_added", (snap) ->
#   for item in denormalize(snap.val())
#     # Filter: must be a new post
#     if item.verb == "add" and item.hasOwnProperty("post_id") #item in ["share", "status", "post", "photo"]
#       time = 10000000000 - parseInt item["__time"]
#       F.child("stream/#{time+hash.MD5(item)}").update(item)

# https://www.npmjs.org/package/node-rest-client
# https://github.com/danwrong/restler
# Twitter - https://dev.twitter.com/docs/api/1.1/post/statuses/update_with_media


