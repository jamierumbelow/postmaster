net = require 'net'
version = require('../package.json').version
Parser = require('./parser').Parser

class exports.Server
    STATES = { default: 1, data: 2, possibly_end_data: 3 }

    constructor: (next, @host = 'localhost', @port = 5666, @quiet = false) ->
        @parser = new Parser()
        @state = STATES.default

        @server = @createServer()
        @server.listen @port, @host, =>
            console.log "Postmaster reporting for duty on #{@host}:#{@port} (HTTP - #{@host}:#{@port+1})" unless @quiet
            next() if next?

        @server.on 'connection', (socket) =>
            socket.setEncoding 'utf8'

            socket.on 'connect', =>
                socket.write "220 #{@host} Postmaster #{version}\n"

            buffer = ''

            socket.on 'data', (data) =>
                lines = (buffer + data).split("\n")
                buffer = lines.pop()

                lines.forEach (line, index) =>
                    @handler(socket, line)

    handler: (socket, data) ->
        email = @newEmail()
        token = if @state is STATES.default then @parser.parseLine(data) else @parser.dataCollection()
        
        # The big if statement below is fine for the majority of cases,
        # however if we're waiting for the end of a DATA body we need to
        # do something extra special.
        if token.meaning is 'data-collection' and @state is STATES.data and data is ""
            @state = STATES.possibly_end_data
        else if token.meaning is 'data-collection' and @state is STATES.possibly_end_data and data is "."
            @state = STATES.default
            socket.write "250 Successsfully saved message (#1)\n"
        else
            @state = STATES.data

        # Carry on! Take a look at each token's "meaning" and set up the
        # email and/or respond in a certain way because of it.
        if token.meaning is 'hello'
            socket.write "250 Hello #{token.args.domain}, nice to meet you\n"

        else if token.meaning is 'from'
            email = @newEmail()
            email.from = token.args.email

            socket.write "250 OK\n"

        else if token.meaning is 'to'
            email.to.push token.args.email
            socket.write "250 OK\n"

        else if token.meaning is 'data-start'
            @state = STATES.data
            email.body = ''

            socket.write "354 OK\n"

        else if token.meaning is 'data-collection'
            email.body += data

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