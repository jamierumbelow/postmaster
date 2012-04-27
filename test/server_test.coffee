net = require 'net'
{Server, VERSION} = require '..'
{testCase} = require 'nodeunit'

module.exports = testCase
    setUp: (next) ->
        @server = new Server =>
            @connection = net.createConnection 5666
            @connection.setEncoding 'utf8'

            next()

    testConnection: (test) ->
        @connection.on 'data', (data) ->
            test.equal data, "220 localhost Postmaster #{VERSION}\r\n"
            test.done()

    tearDown: (next) ->
        @connection.end()
        @server.close()

        next()