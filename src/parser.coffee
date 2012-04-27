class exports.Parser
    COMMANDS = [ 'HELO', 'EHLO', 'MAIL FROM', 'RCPT TO' ]

    parse: (string) ->
        ret = ''

        COMMANDS.forEach (command) ->
            pattern = new RegExp "^#{command}", 'm'
            if pattern.test string
                ret = command

        command: ret