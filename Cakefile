{exec} = require 'child_process'
{print} = require 'util'

task 'build', 'Compile the CoffeeScript source', ->
    exec 'coffee -b -c -o lib src'
    exec 'coffee -b -c test'

task 'run', 'Run an instance of Postmaster', ->
    exec './bin/postmaster'

task 'test', 'Run the Postmaster test suite', ->
    invoke 'build'
    invoke 'run'

    exec './node_modules/.bin/nodeunit test', (err, stdout, stderr) ->
        print stdout if stdout?
        print stderr if stderr?