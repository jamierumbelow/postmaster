# The integration test ensures that the entire application
# works together. While the other tests are unit tests, and thus
# test each individual piece of the application in isolation,
# the integration test tests the flow from the user's perspective.

{testCase} = require 'nodeunit'
spawn = require('child_process').spawn
net = require 'net'
http = require 'http'

module.exports = testCase
    testFlow: (test) ->

        # Fork off and boot up the application
        @postmaster = spawn './bin/postmaster'
        @postmaster.stderr.setEncoding 'utf8'
        @postmaster.stdout.setEncoding 'utf8'
        @postmaster.stderr.on 'data', (data) -> console.log data

        # Wait until we get the "Postmaster reporting for duty" message
        @postmaster.stdout.on 'data', (data) =>

            if data.match /^Postmaster reporting for duty/im

                # First of all, connect to the SMTP server
                smtp = net.createConnection 5666, 'localhost', () =>
                    
                    # We've connected, so go and send us some emails!
                    smtp.write "HELO postmaster-test\n"
                    smtp.write "MAIL FROM:<test@example.com>\n"
                    smtp.write "RCPT TO:<another@example.com>\n"
                    smtp.write "RCPT TO:<different@email.domain.com>\n"
                    smtp.write "DATA\n"
                    smtp.write "Content-Type: text/html\n"
                    smtp.write "Subject: =?utf-8?Q?You_are_a_terrible_human?=\n"
                    smtp.write "User-Agent: Postmaster Integration Tests\n"
                    smtp.write "\n"
                    smtp.write "Hello Mr. Test,\n"
                    smtp.write "\n"
                    smtp.write "I hope you've been having a great day. I'm just writing to inform you that:\n"
                    smtp.write "\n"
                    smtp.write "1. I hate you\n"
                    smtp.write "2. I think you smell terrible. Just terrible.\n"
                    smtp.write "3. You can't hold your drink down, and I tend to have a bigoted attitude toward people that can't drink.\n"
                    smtp.write "\n"
                    smtp.write "If you've got any issues with this email, please don't bother replying, because I won't listen.\n"
                    smtp.write "\n"
                    smtp.write "Lots of love,\n"
                    smtp.write "\n"
                    smtp.write "Kenny\n"
                    smtp.write "\n.\n"

                    # We've got to assume it all worked, because that's what the integration
                    # test is all about! Now, let's connect to the HTTP API and grab them emails
                    api = http.get { port: 5667, host: 'localhost', path: '/emails' }, (socket) =>

                        socket.setEncoding 'utf8'
                        socket.on 'data', (json) =>

                            emails = JSON.parse(json)
                            email = emails['1']

                            test.equal email.from, 'test@example.com'
                            test.equal email.to[0], 'another@example.com'
                            test.equal email.to[1], 'different@email.domain.com'
                            test.equal email.subject, 'You are a terrible human'
                            test.equal email.html, true

                            test.ok email.body.match(/^1. I hate you$/im), "couldn't find '1. I hate you'"
                            test.ok email.body.match(/^Lots of love,$/im), "couldn't find 'Lots of love,'"
                            test.ok email.body.match(/^Hello Mr. Test,$/im), "couldn't find 'Hello Mr. Test,'"

                            @postmaster.kill()
                            test.done()

                        socket.on 'error', (err) =>
                            @postmaster.kill()
                            throw err

                        socket.on 'close', =>
                            @postmaster.kill()

                    # If we can't connect to the API, remember to kill + throw
                    api.on 'error', (err) =>
                        @postmaster.kill()
                        throw err

                    api.on 'close', (had_error) =>
                        @postmaster.kill()                    

                # If we can't connect for whatever reason, kill the process and throw the error
                smtp.on 'error', (err) =>
                    @postmaster.kill()
                    throw err

                smtp.on 'close', (had_error) =>
                    @postmaster.kill()

    tearDown: (next) ->
        @postmaster.kill()
        next()