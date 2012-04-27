# Postmaster

Postmaster is a tiny SMTP server that stores all messages in memory and exposes an HTTP API to retrieve them later. This makes it really easy to test the headers and the content of your emails.

## Installation

Install Postmaster with [npm](http://npmjs.org/):

    $ npm install -g postmaster

You can then run Postmaster with the `postmaster` command, which should be in your path:

    $ postmaster