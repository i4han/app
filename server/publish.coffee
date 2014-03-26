Colors = new Meteor.Collection('colors')
Meteor.publish('colors', -> Colors.find())
