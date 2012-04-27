module.exports =
    Parser: require './parser'
    API: require './api'
    Store: require './store'
    Server: require('./server').Server

    VERSION: require('../package.json').version