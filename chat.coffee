Messages = new Meteor.Collection("messages")
Connections = new Meteor.Collection("connections")


if (Meteor.is_server)
  console.log 'cucu'
#  Meteor.startup ->
#   code to run on server at startup
#    // server code: heartbeat method
#  Meteor.methods
#    keepalive:  (user_id, nick) ->
#      console.log user_id, nick
#      if (!Connections.findOne {user_id: user_id, closed: {$not: {$exists: true}}})
#        Connections.insert({user_id: user_id, nick: nick})
#
#      now = (new Date()).getTime()
#      Connections.update({user_id: user_id}, {$set: {last_seen: now}})

#    // server code: clean up dead clients after 10 seconds
#  Meteor.setInterval( ->
#    now = (new Date()).getTime()
#    Connections.find({last_seen: {$lt: (now - 2 * 1000)}, closed: {$not: {$exists: true}}}).forEach((conn) ->
#      Connections.update({user_id: conn.user_id}, {$set: {closed: true}})
#    )
#  , 1000)
