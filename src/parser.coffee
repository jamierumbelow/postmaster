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