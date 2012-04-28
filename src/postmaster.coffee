module.exports =
    Parser: require('./parser').Parser
    API: require './api'
    Store: require('./store').Store
    Server: require('./server').Server

    VERSION: require('../package.json').version