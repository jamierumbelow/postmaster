{testCase} = require 'nodeunit'
{Server, Store} = require '..'

module.exports = testCase
	setUp: (next) ->
		@oldCreateServer = Server.prototype.createServer
		Server.prototype.createServer = ->
			listen: -> 
			on: ->

		@server = new Server() 

		next()

	tearDown: (next) ->
		Server.prototype.createServer = @oldCreateServer
		next()

	testFrom: (test) ->
		state =
			state: Server.STATES.default
			email: @server.newEmail()
		@socket = { write: (data) => }

		@server.handler @socket, "MAIL FROM:<test@example.com>", state
		test.equal state.email.from, 'test@example.com'
		@server.handler @socket, "MAIL FROM:<other+test@example.com>", state
		test.equal state.email.from, 'other+test@example.com'

		test.done()

	testTo: (test) ->
		state =
			state: Server.STATES.default
			email: @server.newEmail()
		@socket = { write: (data) => }

		@server.handler @socket, "RCPT TO:<email@example.com>", state
		test.equal state.email.to[0], 'email@example.com'
		
		@server.handler @socket, "RCPT TO:<test+email@example.com>", state
		test.equal state.email.to[0], 'email@example.com'
		test.equal state.email.to[1], 'test+email@example.com'

		@server.handler @socket, "RCPT TO:<another+email@example.com>", state
		test.equal state.email.to[0], 'email@example.com'
		test.equal state.email.to[1], 'test+email@example.com'
		test.equal state.email.to[2], 'another+email@example.com'

		@server.handler @socket, "RCPT TO:<one.email@random.example.com>", state
		test.equal state.email.to[0], 'email@example.com'
		test.equal state.email.to[1], 'test+email@example.com'
		test.equal state.email.to[2], 'another+email@example.com'
		test.equal state.email.to[3], 'one.email@random.example.com'

		test.done()

	testDataCollection: (test) ->
		test.expect 21

		state =
			state: Server.STATES.default
			email: @server.newEmail()

		@socket = { write: (data) => test.equal data, "354 OK\n" }

		@server.handler @socket, "DATA", state
		test.equal state.state, Server.STATES.data

		@server.handler @socket, "Header: value\n", state
		test.equal state.state, Server.STATES.data
		test.equal state.email.body, "Header: value\n\n"

		@server.handler @socket, "Some test data", state
		test.equal state.state, Server.STATES.data
		test.equal state.email.body, "Header: value\n\nSome test data\n"

		@server.handler @socket, "More test", state
		test.equal state.state, Server.STATES.data
		test.equal state.email.body, "Header: value\n\nSome test data\nMore test\n"

		@server.handler @socket, "", state
		test.equal state.state, Server.STATES.possibly_end_data
		test.equal state.email.body, "Header: value\n\nSome test data\nMore test\n\n"

		@server.handler @socket, "Love,", state
		test.equal state.state, Server.STATES.data
		test.equal state.email.body, "Header: value\n\nSome test data\nMore test\n\nLove,\n"

		@server.handler @socket, "", state
		test.equal state.state, Server.STATES.possibly_end_data
		test.equal state.email.body, "Header: value\n\nSome test data\nMore test\n\nLove,\n\n"

		random_id = Math.floor(Math.random() * 10) + 1

		@socket = { write: (data) => test.equal data, "250 Successsfully saved message (##{random_id})\n" }
		@store =
			add: (email) =>
				test.equal email.from, ''
				test.equal email.to.length, 0
				test.equal email.body, "Some test data\nMore test\n\nLove,"
				test.equal email.headers['Header'], 'value'

				random_id

		@server.store = @store

		@server.handler @socket, ".", state
		test.equal state.state, Server.STATES.default
		test.equal state.email.body, "Some test data\nMore test\n\nLove,"

		test.done()

	testReset: (test) ->
		state =
			state: Server.STATES.default
			email: { from: 'blah@example.com', to: [ 'another@example.com' ], body: 'blah blah' }
		@socket = { write: (data) => }

		@server.handler @socket, "RSET", state
		test.equal state.email.from, ''
		test.ok state.email.to.length is 0
		test.equal state.email.body, ''

		test.done()