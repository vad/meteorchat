enable_autoscroll = true
nick = amplify.store('nick')

changeNick = (n) ->
  nick = n
  amplify.store('nick', n)

if not nick
  changeNick('User' + Math.floor(Math.random()*1000))

user_id = amplify.store('user_id')
if not user_id
  user_id = Meteor.uuid()
  amplify.store('user_id', user_id)
Session.set 'user_id', user_id
$input = null


tryToChangeNick = (nick_) ->
  old_nick = nick
  if People.findOne({nick: nick_})
    alert("Ghe n'e' za' uno, set ti?")
    return
  changeNick(nick_)
  Connections.update {user_id: Session.get("user_id")}, {$set: {nick: nick}}
  People.update {nick: old_nick}, {$set: {nick: nick}}
  Messages.insert
    event: true
    text: "#{old_nick} is now know as #{nick}"
    from: ""


changeTopic = (topic) ->
  Misc.update({}, {$set: {topic: topic}})
  Messages.insert
    event: true
    text: "#{nick} changed the topic to #{topic}"
    from: ""


insert_message = ->
  val = $input.val()

  return if not val

  $input.val('')

  # commands
  if val[0] is '/'
    first_space = val.indexOf(" ")
    command = val.slice(1, first_space)
    args = val.slice(first_space + 1)
    # change nick?
    if command is 'nick'
      tryToChangeNick(args)
      return
    if command is 'topic'
      changeTopic(args)
      return

    alert "Unknown command"
    return
  Messages.insert
    'from': nick
    'text': val

  $input.val('')


Template.people.is_me = (nick_) ->
  nick_ is nick

Template.chatroom.embed = (text) ->
  key = ""

  if not /https?\:\/\//.test(text)
    return ''

  id_ = Meteor.uuid()
  div_id = "embed-#{id_}"

  url = text
  $.getJSON("http://api.embed.ly/1/oembed?callback=?", {
    key: key
    url: url
    maxwidth: 800
    maxheight: 300
    format: "jsonp"
  }, (data) ->
    console.log data
    $("##{div_id}").html(data.html?)
  )
  return div_id

# ping heartbeat every 5 seconds
Meteor.setInterval( ->
  Meteor.call('keepalive', Session.get('user_id'), nick)
, 3000)

Meteor.startup ->
  Meteor.subscribe("messages")
  Meteor.subscribe("people")
  Meteor.subscribe("misc")

  $input = $('#input')
  $('#submit').click insert_message

  $input.keydown (event) ->
    if event.which is 13
      insert_message()
      event.stopPropagation()

  Meteor.call('keepalive', Session.get('user_id'), nick)

  room = Meteor.ui.render ->
    Template.chatroom
      'messages': Messages.find({})
      'misc': Misc.findOne()

  $('.room').append(room)

  people = Meteor.ui.render ->
    Template.people
      'people': People.find()

  $('.people').append(people)

  # autoscroll
  $scrollable = $('#content')
  scrollable = $scrollable[0]
  $scrollable.scroll (event) ->
    enable_autoscroll = false
    if $scrollable.height() is (scrollable.scrollHeight - scrollable.scrollTop)
      enable_autoscroll = true

  # autoscroll: add a message, should i scroll?
  Messages.find().observe
    added: ->
      setTimeout(->
        if enable_autoscroll
          scrollable.scrollByPages(100)
      , 10)

  $input.focus()

