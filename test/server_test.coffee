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
        , 'localhost', 5666, true

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

    testFrom: (test) ->
        onResponse @connection, (data) ->
            test.equal data, "250 OK"
            test.done()

        @connection.write "MAIL FROM:<test@example.com>\n"

    testTo: (test) ->
        n = 1

        onResponse @connection, (data) ->
            test.equal data, "250 OK"
            test.done() if n is 5
            n++
            
        @connection.write "RCPT TO:<other@example.com>\n"
        @connection.write "RCPT TO:<another@example.com>\n"
        @connection.write "RCPT TO:<some.other+email@example.com>\n"
        @connection.write "RCPT TO:<again@another.example.com>\n"
        @connection.write "RCPT TO:<weird.example+email@another.example.com>\n"

    testData: (test) ->
        n = 1

        onResponse @connection, (data) ->
            if n is 1
                test.equal(data, "354 OK") 
            else if n is 2
                test.equal(data, "250 Successsfully saved message (#1)")
                test.done()

            n++

        @connection.write "DATA\n"
        @connection.write "\n"
        @connection.write "Hello everyone,\n"
        @connection.write "This is a test of Postmaster\n"
        @connection.write "\n.\n"

    testIncorrectVerb: (test) ->
        onResponse @connection, (data) ->
            test.equal data, '502 Command Not Implemented'
            test.done()

        @connection.write "SOME COMMAND\n"

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