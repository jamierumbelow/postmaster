net = require 'net'
version = require('../package.json').version

class exports.Server
    constructor: (next, @host = 'localhost', @port = 5666) ->
        @server = @createServer()
        @server.listen @port, @host, =>
            console.log "Postmaster reporting for duty on #{@host}:#{@port}"
            next()

    handler: (socket) ->
        socket.write "220 #{@host} Postmaster #{version}\r\n"

    createServer: ->
        net.createServer (socket) =>
            @handler(socket)

    close: ->
        @server.close()