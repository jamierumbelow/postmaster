net = require 'net'

class exports.Server
    constructor: (@host = 'localhost', @port = 5666) ->
        @createServer().listen @port, @host, =>
            console.log "Postmaster reporting for duty on #{@host}:#{@port}"

    handler: (socket) ->
        socket.write 'Welcome to Postmaster\n'

    createServer: ->
        net.createServer @handler