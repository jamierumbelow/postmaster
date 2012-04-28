http = require 'http'
{testCase} = require 'nodeunit'
{API} = require '..'

module.exports = testCase
    setUp: (next) ->
        @api = new API 'localhost', 5667, =>
            next()

    testServerIsCreated: (test) ->
        test.ok (@api.server instanceof http.Server), '@api.server isn\'t an instance of http.Server'

        getRequest 'localhost', 5667, '/', (data) =>
            test.equal data, 'Hello World!'
            test.ok(true)

            test.done()

    tearDown: (next) ->
        @api.server.close()
        next()

getRequest = (host, port, path, next) ->
    http.get { host: host, port: port, path: path}, (res) ->
        res.on 'data', (data) ->
            next data.toString()