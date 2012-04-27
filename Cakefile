{exec} = require 'child_process'
{print} = require 'util'

task 'build', 'Compile the CoffeeScript source', ->
    exec 'coffee -b -c -o lib src'

task 'test', 'Run the Postmaster test suite', ->
    invoke 'build'

    exec './node_modules/.bin/nodeunit test', (err, stdout, stderr) ->
        print stdout if stdout?
        print stderr if stderr?