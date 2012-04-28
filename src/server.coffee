net = require 'net'
version = require('../package.json').version
Parser = require('./parser').Parser
Store = require('./store').Store

class exports.Server
    @STATES = { default: 1, data: 2, possibly_end_data: 3 }

    constructor: (next, @host = 'localhost', @port = 5666, @quiet = false, @store = false) ->
        STATES = Server.STATES
        @parser = new Parser()

        @server = @createServer()
        @server.listen @port, @host, =>
            console.log "Postmaster reporting for duty on #{@host}:#{@port} (HTTP - #{@host}:#{@port+1})" unless @quiet
            next() if next?

        @server.on 'connection', (socket) =>
            socket.setEncoding 'utf8'

            socket.on 'connect', =>
                socket.write "220 #{@host} Postmaster #{version}\n"

            buffer = ''
            state =
                state: STATES.default
                email: @newEmail()

            socket.on 'data', (data) =>
                lines = (buffer + data).split("\n")
                buffer = lines.pop()

                lines.forEach (line, index) =>
                    @handler(socket, line, state)

    handler: (socket, line, state) ->
        STATES = Server.STATES
        token = if state.state is STATES.default then @parser.parseLine(line) else @parser.dataCollection()

        # The big if statement below is fine for the majority of cases,
        # however if we're waiting for the end of a DATA body we need to
        # do something extra special.
        #
        # If it's the data state and it's a blank newline, we could possibly
        # be about to end the data collection phase.
        if token.meaning is 'data-collection' and state.state is STATES.data and line is ""
            state.state = STATES.possibly_end_data

        # If it's the data collection phase but we could possibly be about to end,
        # check if it's a period (implicitly followed by a newline). If it is, then
        # we need to get out of this state posthaste!
        else if token.meaning is 'data-collection' and state.state is STATES.possibly_end_data and line is "."
            state.state = STATES.default

            email = state.email
            body = state.email.body.substring(0, state.email.body.length - 2)

            state.email = @parser.parseEmail(body)
            state.email.from = email.from
            state.email.to = email.to

            id = @store.add state.email

            return socket.write "250 Successsfully saved message (##{id})\n"

        # If we've made it this far and we're in the data state, then ensure we stay
        # that way. If not, go back to default.
        else if state.state is STATES.data or state.state is STATES.possibly_end_data
            state.state = STATES.data
        else
            state.state = STATES.default

        # Carry on! Take a look at each token's "meaning" and set up the
        # email and/or respond in a certain way because of it.

        # Is it a HELO or EHLO command?
        if token.meaning is 'hello'
            socket.write "250 Hello #{token.args.domain}, nice to meet you\n"

        # Is it a MAIL FROM command? If it is, create a new email and set
        # our from data to be the passed parameter
        else if token.meaning is 'from'
            state.email = @newEmail()
            state.email.from = token.args.email

            socket.write "250 OK\n"

        # Is it a RCPT TO command? If it is, add our email to the to list!
        else if token.meaning is 'to'
            state.email.to.push token.args.email
            socket.write "250 OK\n"

        # Is it a DATA command? Set our state to be in the data state and 
        # get ready to read in the email
        else if token.meaning is 'data-start'
            state.state = STATES.data
            socket.write "354 OK\n"

        # Are we in the data collection phase? If the line is empty, it'll be a newline
        # so make sure we account for that. If not, add away!
        else if token.meaning is 'data-collection'
            if line is ""
                state.email.body += "\n"
            else
                state.email.body += line + "\n"

        # Is it a ping message?
        else if token.meaning is 'ping'
            socket.write "250 OK\n"

        # Is it a reset command?
        else if token.meaning is 'reset'
            state.email = @newEmail()
            socket.write "250 OK\n"

        # Is it the quit command?
        else if token.meaning is 'quit'
            socket.end()

        # WE DON'T NEED NO EDUCATION
        else if token.meaning is 'info'
            socket.write "214 Postmaster is a fake SMTP server used for testing.\n"
            socket.write "214 For more, please visit https://github.com/jamierumbelow/postmaster\n"

        # The parser couldn't understand the command passed in, or the syntax
        # was bad, so respond accordingly.
        else if token.meaning is 'wtf'
            socket.write "502 Command Not Implemented\n"

        else
            socket.write "500 Syntax Error\n"

    newEmail: ->
        { from: '', to: [], body: '' }

    createServer: ->
        net.createServer()

    close: ->
        @server.close()