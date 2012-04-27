net = require 'net'
{server} = require '..'
{testCase} = require 'nodeunit'

module.exports = testCase
    setUp: (next) ->
        @connection = net.createConnection 25
        next()

    testHello: (test) ->
        test.ok(true)
        test.done()

    tearDown: (next) ->
        @connection.end()
        next()