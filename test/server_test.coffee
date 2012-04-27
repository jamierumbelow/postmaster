net = require 'net'
{Server, VERSION} = require '..'
{testCase} = require 'nodeunit'

module.exports = testCase

    # Boot up a new Server to run our tests on. Once the server
    # is booted, also open up a socket to the server so we can 
    # begin our test suite.
    setUp: (next) ->
        @server = new Server =>
            @connection = net.createConnection 5666
            @connection.setEncoding 'utf8'

            next()

    # Close the connection to our server, followed by the server itself
    tearDown: (next) ->
        @connection.end()
        @server.close()

        next()

    testConnection: (test) ->
        @connection.on 'data', (data) ->
            test.equal data, "220 localhost Postmaster #{VERSION}\n"
            test.done()

    testHello: (test) ->
        onResponse @connection, (data) ->
            test.equal data, "250 Hello postmaster-test-connection, nice to meet you"
            test.done()

        @connection.write "HELO postmaster-test-connection\n"

    testOtherHello: (test) ->
        onResponse @connection, (data) ->
            test.equal data, "250 Hello other-test-connection, nice to meet you"
            test.done()

        @connection.write "HELO other-test-connection\n"

    testEhlo: (test) ->
        onResponse @connection, (data) ->
            test.equal data, "250 Hello postmaster-test-connection, nice to meet you"
            test.done()

        @connection.write "EHLO postmaster-test-connection\n"

#
# -----------------------------------------------------------------------
#

# Splits up the response data into lines and executes the callback for each line,
# accounting for the initial connection line (220)
onResponse = (connection, next) ->
    buffer = ''

    connection.on 'data', (data) ->
        lines = (buffer + data).split("\n")
        buffer = lines.pop()

        lines.forEach (line, index) ->
            if line[0...3] isnt '220'
                next(line)