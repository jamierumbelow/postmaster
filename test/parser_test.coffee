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

    testParsesHelloArguments: (test) ->
        test.equal(@parser.parse('HELO blah-blah-blah').args.domain, 'blah-blah-blah')
        test.equal(@parser.parse('HELO blah-different-blah').args.domain, 'blah-different-blah')
        test.equal(@parser.parse('EHLO blah-blah-blah').args.domain, 'blah-blah-blah')
        test.equal(@parser.parse('EHLO blah-blah-yo').args.domain, 'blah-blah-yo')

        test.done()

    testParsesFromArguments: (test) ->
        test.equal(@parser.parse('MAIL FROM:<test@example.com>').args.email, 'test@example.com')
        test.equal(@parser.parse('MAIL FROM:<jamie@jamierumbelow.net>').args.email, 'jamie@jamierumbelow.net')
        test.equal(@parser.parse('MAIL FROM:<jamie+postmaster@jamierumbelow.net>').args.email, 'jamie+postmaster@jamierumbelow.net')
        test.equal(@parser.parse('MAIL FROM:<other.email@other.domain.com>').args.email, 'other.email@other.domain.com')

        test.done()

    testParsesToArguments: (test) ->
        test.equal(@parser.parse('RCPT TO:<test@example.com>').args.email, 'test@example.com')
        test.equal(@parser.parse('RCPT TO:<jamie@jamierumbelow.net>').args.email, 'jamie@jamierumbelow.net')
        test.equal(@parser.parse('RCPT TO:<jamie+postmaster@jamierumbelow.net>').args.email, 'jamie+postmaster@jamierumbelow.net')
        test.equal(@parser.parse('RCPT TO:<other.email@other.domain.com>').args.email, 'other.email@other.domain.com')

        test.done()