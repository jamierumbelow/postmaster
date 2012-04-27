class exports.Parser
    COMMANDS = [ 'HELO', 'EHLO', 'MAIL FROM', 'RCPT TO' ]

    parse: (string) ->
        command = ''

        COMMANDS.forEach (cmd) ->
            if (new RegExp "^#{cmd}", 'm').test string
                command = cmd

        args = this["parse#{command.replace(' ', '')}"](string) if this["parse#{command.replace(' ', '')}"]?

        command: command
        args: args

    parseHELO: (string) ->
        domain: string.match(/^(HELO|EHLO) (.*)$/m)[2]
    
    parseEHLO: (string) -> @parseHELO(string)

    parseMAILFROM: (string) ->
        email: string.match(/^MAIL FROM:<(.*)>$/m)[1]

    parseRCPTTO: (string) ->
        email: string.match(/^RCPT TO:<(.*)>$/m)[1]