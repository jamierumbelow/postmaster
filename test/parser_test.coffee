Parser = require('..').Parser
{testCase} = require 'nodeunit'

module.exports = testCase
    setUp: (next) ->
        @parser = new Parser()
        next()

    testParsesCommand: (test) ->
        test.ok((typeof @parser.parseLine('HELO blah blah blah') is 'object'), '.parse() doesn\'t return an object')
        test.equal(@parser.parseLine('HELO blah blah blah').command, 'HELO')
        test.equal(@parser.parseLine('EHLO blah blah blah').command, 'EHLO')
        test.equal(@parser.parseLine('MAIL FROM:<test@example.com>').command, 'MAIL FROM')
        test.equal(@parser.parseLine('RCPT TO:<other@example.com>').command, 'RCPT TO')
        test.equal(@parser.parseLine('DATA').command, 'DATA')
        test.equal(@parser.parseLine('RSET').command, 'RSET')
        test.equal(@parser.parseLine('NOOP').command, 'NOOP')
        test.equal(@parser.parseLine('QUIT').command, 'QUIT')
        test.equal(@parser.parseLine('HELP').command, 'HELP')

        test.done()

    testParsesMeaning: (test) -> 
        test.equal(@parser.parseLine('HELO blah blah blah').meaning, 'hello')
        test.equal(@parser.parseLine('EHLO blah blah blah').meaning, 'hello')
        test.equal(@parser.parseLine('MAIL FROM:<test@example.com>').meaning, 'from')
        test.equal(@parser.parseLine('RCPT TO:<other@example.com>').meaning, 'to')
        test.equal(@parser.parseLine('DATA').meaning, 'data-start')
        test.equal(@parser.parseLine('RSET').meaning, 'reset')
        test.equal(@parser.parseLine('NOOP').meaning, 'ping')
        test.equal(@parser.parseLine('QUIT').meaning, 'quit')
        test.equal(@parser.parseLine('HELP').meaning, 'info')

        test.done()

    testParsesHelloArguments: (test) ->
        test.equal(@parser.parseLine('HELO blah-blah-blah').args.domain, 'blah-blah-blah')
        test.equal(@parser.parseLine('HELO blah-different-blah').args.domain, 'blah-different-blah')
        test.equal(@parser.parseLine('EHLO blah-blah-blah').args.domain, 'blah-blah-blah')
        test.equal(@parser.parseLine('EHLO blah-blah-yo').args.domain, 'blah-blah-yo')

        test.done()

    testParsesFromArguments: (test) ->
        test.equal(@parser.parseLine('MAIL FROM:<test@example.com>').args.email, 'test@example.com')
        test.equal(@parser.parseLine('MAIL FROM:<jamie@jamierumbelow.net>').args.email, 'jamie@jamierumbelow.net')
        test.equal(@parser.parseLine('MAIL FROM:<jamie+postmaster@jamierumbelow.net>').args.email, 'jamie+postmaster@jamierumbelow.net')
        test.equal(@parser.parseLine('MAIL FROM:<other.email@other.domain.com>').args.email, 'other.email@other.domain.com')

        test.done()

    testParsesToArguments: (test) ->
        test.equal(@parser.parseLine('RCPT TO:<test@example.com>').args.email, 'test@example.com')
        test.equal(@parser.parseLine('RCPT TO:<jamie@jamierumbelow.net>').args.email, 'jamie@jamierumbelow.net')
        test.equal(@parser.parseLine('RCPT TO:<jamie+postmaster@jamierumbelow.net>').args.email, 'jamie+postmaster@jamierumbelow.net')
        test.equal(@parser.parseLine('RCPT TO:<other.email@other.domain.com>').args.email, 'other.email@other.domain.com')

        test.done()

    testInvalidCommandsReturnWTF: (test) ->
        test.equal(@parser.parseLine('SOME OTHER COMMAND').command, 'WTF')
        test.equal(@parser.parseLine('SOME OTHER COMMAND:params').command, 'WTF')
        test.equal(@parser.parseLine('SOME OTHER COMMAND').meaning, 'wtf')
        test.equal(@parser.parseLine('SOME OTHER COMMAND:params').meaning, 'wtf')

        test.done()