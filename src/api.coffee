http = require 'http'

class exports.API
    constructor: (host, port, next) ->
        @server = http.createServer (req, res) => 
            @handle(req, res)
        @server.listen port, host, ->
            next() if next?

    handle: (req, res) ->
        res.writeHead(200)
        res.end 'Hello World!'