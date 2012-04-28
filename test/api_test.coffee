http = require 'http'
{testCase} = require 'nodeunit'
{API} = require '..'

module.exports = testCase
    setUp: (next) ->
        @api = new API 'localhost', 5667, =>
            next()

    testServerIsCreated: (test) ->
        test.ok (@api.server instanceof http.Server), '@api.server isn\'t an instance of http.Server'

        getRequest 'localhost', 5667, '/ping', (data) =>
            test.equal data, '<a href="https://github.com/jamierumbelow/postmaster">Postmaster</a> reporting for duty'

            test.done()

    testServerThrows404: (test) ->
        getRequest 'localhost', 5667, '/jkljfoiwuro8aw8fw498', (data, res) =>
            test.equal data, '<h1>404 Not Found</h1>'
            test.equal res.statusCode, 404

            test.done()

    tearDown: (next) ->
        @api.server.close()
        next()

getRequest = (host, port, path, next) ->
    http.get { host: host, port: port, path: path}, (res) ->
        res.on 'data', (data) ->
            next data.toString(), res