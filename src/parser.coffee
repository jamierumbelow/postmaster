mimelib = require 'mimelib'

class exports.Parser
    COMMANDS = [ 'HELO', 'EHLO', 'MAIL FROM', 'RCPT TO', 'DATA', 'RSET', 'NOOP', 'QUIT', 'HELP' ]

    parseLine: (string) ->
        command = ''

        COMMANDS.forEach (cmd) ->
            if (new RegExp "^#{cmd}", 'm').test string
                command = cmd

        if command is ''
            command = 'WTF'

        args = this["parse#{command.replace(' ', '')}"](string) if this["parse#{command.replace(' ', '')}"]?
        meaning = args.meaning
        delete args['meaning']

        command: command
        args: args
        meaning: meaning

    parseHELO: (string) ->
        domain: string.match(/^(HELO|EHLO) (.*)$/m)[2]
        meaning: 'hello'
    
    parseEHLO: (string) -> @parseHELO(string)

    parseMAILFROM: (string) ->
        email: string.match(/^MAIL FROM:<(.*)>$/m)[1]
        meaning: 'from'

    parseRCPTTO: (string) ->
        email: string.match(/^RCPT TO:<(.*)>$/m)[1]
        meaning: 'to'

    parseDATA: (string) ->
        meaning: 'data-start'

    parseRSET: (string) ->
        meaning: 'reset'

    parseNOOP: (string) ->
        meaning: 'ping'

    parseQUIT: (string) ->
        meaning: 'quit'

    parseHELP: (string) ->
        meaning: 'info'

    parseWTF: (string) ->
        meaning: 'wtf'

    dataCollection: (string) ->
        meaning: 'data-collection'

    # Parse an email message body, extracting headers and other important
    # information and separating headers and content itself.
    parseEmail: (email) ->
        [ unparsed_headers, body ] = email.split "\n\n"

        unparsed_headers = unparsed_headers.split "\n"
        headers = {}

        for h in unparsed_headers
            match = h.match /^([A-Za-z0-9\-_]+): (.*)$/im
            headers[match[1]] = match[2] if match

        headers: headers
        body: body
        html: (if headers['Content-Type']? then !!headers['Content-Type'].match(/html/i) else false)
        subject: (if headers['Subject'] then @parseSubject(headers['Subject']) else false)

    parseSubject: (header) ->
        mimelib.decodeMimeWord(header)