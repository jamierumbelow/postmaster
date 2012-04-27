{exec} = require 'child_process'
{print} = require 'util'

option '-t', '--test-file [file]', 'run a specific path when using cake test'

task 'build', 'Compile the CoffeeScript source', ->
    exec 'coffee -b -c -o lib src'

task 'test', 'Run the Postmaster test suite', (options) ->
    invoke 'build'

    run = if options['test-file']? then options['test-file'] else 'test'
    
    exec './node_modules/.bin/nodeunit ' + run, (err, stdout, stderr) ->
        print stdout if stdout?
        print stderr if stderr?