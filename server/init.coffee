Meteor.startup ->
  # code to run on server at startup
  #    // server code: heartbeat method
  Meteor.methods
    keepalive:  (user_id, nick) ->
#        console.log 'keepalive', Connections.findOne({user_id: user_id})
      conn = Connections.findOne {user_id: user_id}
      if not conn
        console.log 'create', user_id
        Connections.insert({user_id: user_id, nick: nick})
        People.insert({nick: nick})
      else if conn.closed
        console.log 'reopen', user_id
        Connections.update({user_id: user_id}, {$unset: {closed: 1}})
        People.insert({nick: nick})

      now = (new Date()).getTime()
      Connections.update({user_id: user_id}, {$set: {last_seen: now}})

#      // server code: clean up dead clients after 10 seconds
  Meteor.setInterval( ->
    now = (new Date()).getTime()
    Connections.find({last_seen: {$lt: (now - 2 * 1000)}, closed: {$not: {$exists: true}}}).forEach((conn) ->
      console.log 'closing', conn.user_id, conn.last_seen
      Connections.update({user_id: conn.user_id}, {$set: {closed: true}})
      People.remove({nick: conn.nick})
    )
  , 10000)

  # if no settings, create an empty one
  console.log Misc.findOne({})
  if not Misc.findOne({})
    Misc.insert({topic: ''})

  Meteor.publish("messages", ->
    Messages.find()
  )

  Meteor.publish("people", ->
    People.find()
  )

  Meteor.publish("misc", ->
    Misc.find()
  )
