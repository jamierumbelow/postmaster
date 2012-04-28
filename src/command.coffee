postmaster = require '..'
util = require 'util'
program = require 'commander'

process.title = 'postmaster'

program
  .version(postmaster.VERSION)
  .option('-l, --listen [host]', 'Which host to listen on [localhost]', 'localhost')
  .option('-p, --port [port]', 'Port number [5666]', parseInt, 5666)
  .option('-q, --quiet', 'Silence output')
  .parse(process.argv)

store = new postmaster.Store()

server = new postmaster.Server null, program.listen, program.port, (program.quiet?), store
api = new postmaster.API program.listen, program.port + 1, null, store