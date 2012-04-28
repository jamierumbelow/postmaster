http = require 'http'
{testCase} = require 'nodeunit'
{API, Store, Parser} = require '..'

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

    testReturnsAllEmails: (test) ->
        testEmail =
            from: 'test@example.com'
            to: [ 'another@test.example.com' ]
            body: 'User-Agent: CodeIgniter\nDate: Sat, 28 Apr 2012 15:21:17 +0100\nFrom: <test@example.com>\nReturn-Path: <test@example.com>\nTo: jamie@jamierumbelow.net\nSubject: =?utf-8?Q?Some_random_email?=\nReply-To: "test@example.com" <test@example.com>\nX-Sender: test@example.com\nX-Mailer: CodeIgniter\nX-Priority: 3 (Normal)\nMessage-ID: <4f9bfcdd7499e@example.com>\nMime-Version: 1.0\nContent-Type: text/plain; charset=utf-8\nContent-Transfer-Encoding: 8bit\n\nOh yeah'

        @parser = new Parser()
        
        email = testEmail

        testEmail = @parser.parseEmail(testEmail.body)
        testEmail.from = email.from
        testEmail.to = email.to
        
        @store = new Store()
        @store.add testEmail
        
        @api.server.close()
        @api = new API 'localhost', 5667, null, @store

        getRequest 'localhost', 5667, '/emails', (data, res) =>
            test.equal data, JSON.stringify({ 1: testEmail })
            test.equal res.statusCode, 200
            test.equal res.headers['content-type'], 'application/json'

            test.done()

    tearDown: (next) ->
        @api.server.close()
        next()

getRequest = (host, port, path, next) ->
    http.get { host: host, port: port, path: path}, (res) ->
        res.on 'data', (data) ->
            next data.toString(), res