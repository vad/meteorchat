Messages = new Meteor.Collection("messages")
Connections = new Meteor.Collection("connections")
People = new Meteor.Collection("people")
Misc = new Meteor.Collection("misc")


insert_message = (from, text) ->
  Messages.insert
    time: new Date()
    text: text
    from: from

insert_event = (text) ->
  Messages.insert
    time: new Date()
    text: text
    from: ""
    event: true
