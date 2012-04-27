net = require 'net'
version = require('../package.json').version

class exports.Server
    constructor: (next, @host = 'localhost', @port = 5666) ->
        @server = @createServer()
        @server.listen @port, @host, =>
            console.log "Postmaster reporting for duty on #{@host}:#{@port} (HTTP - #{@host}:#{@port+1})"
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
        if data[0...4] is "HELO" or data[0...4] is "EHLO"
            name = data.match(/^(HELO|EHLO) (.*)$/m)[2]
            socket.write "250 Hello #{name}, nice to meet you\n"

    createServer: ->
        net.createServer()

    close: ->
        @server.close()