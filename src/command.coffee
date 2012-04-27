postmaster = require '..'
util = require 'util'
program = require 'commander'

process.title = 'postmaster'

program
  .version(postmaster.VERSION)
  .option('-l, --listen [host]', 'Which host to listen on [localhost]', 'localhost')
  .option('-p, --port [port]', 'Port number [5666]', parseInt, 5666)
  .parse(process.argv)

server = new postmaster.Server null, program.listen, program.port