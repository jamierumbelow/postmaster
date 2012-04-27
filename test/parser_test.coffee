Parser = require('..').Parser
{testCase} = require 'nodeunit'

module.exports = testCase
    setUp: (next) ->
        @parser = new Parser()
        next()

    testParsesCommand: (test) ->
        test.ok((typeof @parser.parse('HELO blah blah blah') is 'object'), '.parse() doesn\'t return an object')
        test.equal(@parser.parse('HELO blah blah blah').command, 'HELO')
        test.equal(@parser.parse('EHLO blah blah blah').command, 'EHLO')
        test.equal(@parser.parse('MAIL FROM:<test@example.com>').command, 'MAIL FROM')
        test.equal(@parser.parse('RCPT TO:<other@example.com>').command, 'RCPT TO')

        test.done()