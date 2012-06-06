nick = 'User' + Math.floor(Math.random()*1000)
#  Session.set('nick', nick)
Session.set 'user_id', Meteor.uuid()
$input = null

insert_message = ->
  val = $input.val()
  $input.val('')

  if val[0] is '/'
    nick_groups = /\/nick ([a-zA-Z0-9]+)/.exec(val)
    if nick_groups
      nick = nick_groups[1]
      console.log nick, nick_groups
      Connections.update {user_id: Session.get("user_id")}, {$set: {nick: nick}}
      return
    alert "Unknown command"
    return
  Messages.insert
    'from': Session.get('user_id')
    'text': val

  $input.val('')

Template.chatroom.fromName = (user_id) ->
  Connections.findOne({user_id: user_id}).nick

Template.people.is_me = (user_id) ->
  user_id is Session.get 'user_id'

#    // client code: ping heartbeat every 5 seconds
Meteor.setInterval( ->
  Meteor.call('keepalive', Session.get('user_id'), nick)
, 2000)

Meteor.startup ->
  $input = $('#input')
  $('#submit').click insert_message

  $input.keydown (event) ->
    if event.which is 13
      insert_message()
      event.stopPropagation()

  Connections.insert
    user_id: Session.get('user_id')
    nick: nick

  room = Meteor.ui.render ->
    Template.chatroom
      'messages': Messages.find()

  $('.room').append(room)

  people = Meteor.ui.render ->
    Template.people
      'people': Connections.find
        closed:
          $not:
            $exists: true

  $('.people').append(people)

