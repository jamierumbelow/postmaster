# Postmaster

Postmaster is a tiny SMTP server that stores all messages in memory and exposes an HTTP API to retrieve them later. This makes it really easy to test the headers and the content of your emails.

## Installation

Install Postmaster with [npm](http://npmjs.org/):

    $ npm install -g postmaster

You can then run Postmaster with the `postmaster` command, which should be in your path:

    $ postmaster
    > Postmaster reporting for duty on localhost:5666 (HTTP - localhost:5667)

Change the bound hostname and port with the `-l` and `-p` flags, respectively:

    $ postmaster -p 4432 -l 127.0.0.1
    > Postmaster reporting for duty on 127.0.0.1:4432 (HTTP - 127.0.0.1:4433)

## HTTP API

The HTTP API will open up on the next port from the Postmaster port. Sending an `HTTP GET` request to `/emails` will return a JSON array of the parsed email and associated headers.

    $ curl http://localhost:5667/emails

## Development / Tests

Grab the most recent copy of the codebase from GitHub:

    $ git clone git://github.com/jamierumbelow/postmaster.git postmaster

Install yer modules:

    $ npm install

And run the test suite with cake!

    $ cake test

If you're developing locally and would like an easy way to rebuild the source, run `cake build`:

    $ cake build && ./bin/postmaster