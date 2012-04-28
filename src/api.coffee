http = require 'http'

class exports.API
    constructor: (host, port, next, @store) ->
        @server = http.createServer (req, res) => 
            @handle(req, res)
        @server.listen port, host, ->
            next() if next?

    handle: (req, res) ->
        if req.url is '/emails'
            res.writeHead 200, { 'Content-Type': 'application/json' }
            res.end JSON.stringify(@store.all())

        else if req.url is '/ping'
            res.writeHead 200, { 'Content-Type': 'text/html' }
            res.end '<a href="https://github.com/jamierumbelow/postmaster">Postmaster</a> reporting for duty'

        else
            res.writeHead 404, { 'Content-Type': 'text/html' }
            res.end '<h1>404 Not Found</h1>'