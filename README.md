# Postmaster

Postmaster is a tiny SMTP server that stores all messages in memory and exposes an HTTP API to retrieve them later. This makes it really easy to test the headers and the content of your emails.

## Installation

Install Postmaster with [npm](http://npmjs.org/):

    $ npm install -g postmaster

You can then run Postmaster with the `postmaster` command, which should be in your path:

    $ postmaster
    Postmaster reporting for duty on localhost:5666 (HTTP - localhost:5667)

Change the bound hostname and port with the `-l` and `-p` flags, respectively:

    $ postmaster -p 4432 -l 127.0.0.1
    Postmaster reporting for duty on 127.0.0.1:4432 (HTTP - 127.0.0.1:4433)

## HTTP API

The HTTP API will open up on the next port from the Postmaster port. Sending an `HTTP GET` request to `/emails` will return a JSON array of the parsed email and associated headers.

    $ curl http://localhost:5667/emails
    {"1":{"headers":{"User-Agent":"CodeIgniter","Date":"Sat, 28 Apr 2012 17:49:55 +0100","From":"<test@example.com>","Return-Path":"<test@example.com>","To":"another@example.com","Subject":"=?utf-8?Q?Some_random_email?=","Reply-To":"\"test@example.com\" <test@example.com>","X-Sender":"test@example.com","X-Mailer":"CodeIgniter","X-Priority":"3 (Normal)","Message-ID":"<4f9c1fb3d6878@example.com>","Mime-Version":"1.0","Content-Type":"text/plain; charset=utf-8","Content-Transfer-Encoding":"8bit"},"body":"Oh yeah","html":false,"subject":"Some random email","from":"test@example.com","to":["another@example.com"]}}

Piped through a JSON prettifier, the output looks like this:

    $ curl -s http://localhost:5667/emails | python -mjson.tool
    {
        "1": {
            "body": "Oh yeah", 
            "from": "test@example.com", 
            "headers": {
                "Content-Transfer-Encoding": "8bit", 
                "Content-Type": "text/plain; charset=utf-8", 
                "Date": "Sat, 28 Apr 2012 17:49:55 +0100", 
                "From": "<test@example.com>", 
                "Message-ID": "<4f9c1fb3d6878@example.com>", 
                "Mime-Version": "1.0", 
                "Reply-To": "\"test@example.com\" <test@example.com>", 
                "Return-Path": "<test@example.com>", 
                "Subject": "=?utf-8?Q?Some_random_email?=", 
                "To": "jamie@jamierumbelow.net", 
                "User-Agent": "CodeIgniter", 
                "X-Mailer": "CodeIgniter", 
                "X-Priority": "3 (Normal)", 
                "X-Sender": "test@example.com"
            }, 
            "html": false, 
            "subject": "Some random email", 
            "to": [
                "jamie@jamierumbelow.net"
            ]
        }
    }

The email's original headers and body are stored and returned, alongside the parsed subject, whether or not the email is HTML, and the from/to address(es).

## PHP Example

Assuming we've got an application sending out an email when the user is registered, and we want to test it, we can boot up Postmaster, run the register method and check the HTTP API very easily:

    <?php

    class Register_Test extends PHPUnit_Framework_TestCase
    {
        function testRegistration()
        {
            // Fork out the Postmaster binary and wait until it's ready
            $postmaster = popen('postmaster', 'r');
            $output = fread($postmaster);

            // Register our user
            $model = new User_model();
            $model->register('test_email@domain.com', 'test_password');

            // Grab our emails
            $curl = curl_init('http://localhost:5667/emails');
            curl_setopt($curl, CURLOPT_RETURNTRANSFER, TRUE);

            $json = curl_exec($curl);
            curl_close();

            $emails = (array)json_decode($json);

            // Check that the email is what it's supposed to be!
            $this->assertEqual($emails['1']->from, 'hello@myapp.com');
            $this->assertEqual($emails['1']->to, 'test_email@domain.com');
            $this->assertEqual($emails['1']->subject, 'MyApp - Welcome to MyApp!');

            // Kill the process
            pclose($postmaster);
        }
    }

## Development / Tests

Grab the most recent copy of the codebase from GitHub:

    $ git clone git://github.com/jamierumbelow/postmaster.git postmaster

Install yer modules:

    $ npm install

And run the test suite with cake!

    $ cake test

If you're developing locally and would like an easy way to rebuild the source, run `cake build`:

    $ cake build && ./bin/postmaster