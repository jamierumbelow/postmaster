{testCase} = require 'nodeunit'
{Store} = require '..'

module.exports = testCase
    setUp: (next) ->
        @store = new Store()

        next()

    testAdd: (test) ->
        email = { from: 'test@example.com', to: [ 'another@example.com' ], body: 'Some email!' }
        
        test.equal @store.add(email), 1
        test.equal @store.emails.length(), 1
        test.equal @store.emails[1], email
        test.equal @store.ids.length, 1
        test.equal @store.ids[0], 1

        test.equal @store.add(email), 2
        test.equal @store.emails.length(), 2
        test.equal @store.emails[2], email
        test.equal @store.ids.length, 2
        test.equal @store.ids[1], 2

        test.done()

    testRemove: (test) ->
        email = { from: 'test@example.com', to: [ 'another@example.com' ], body: 'Some email!' }
        
        @store.remove @store.add(email)

        test.equal @store.emails.length(), 0
        test.equal @store.ids.length, 0

        test.done()