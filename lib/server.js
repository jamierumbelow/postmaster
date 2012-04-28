var Parser, net, version;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
net = require('net');
version = require('../package.json').version;
Parser = require('./parser').Parser;
exports.Server = (function() {
  Server.STATES = {
    "default": 1,
    data: 2,
    possibly_end_data: 3
  };
  function Server(next, host, port, quiet) {
    var STATES;
    this.host = host != null ? host : 'localhost';
    this.port = port != null ? port : 5666;
    this.quiet = quiet != null ? quiet : false;
    STATES = Server.STATES;
    this.parser = new Parser();
    this.server = this.createServer();
    this.server.listen(this.port, this.host, __bind(function() {
      if (!this.quiet) {
        console.log("Postmaster reporting for duty on " + this.host + ":" + this.port + " (HTTP - " + this.host + ":" + (this.port + 1) + ")");
      }
      if (next != null) {
        return next();
      }
    }, this));
    this.server.on('connection', __bind(function(socket) {
      var buffer, state;
      socket.setEncoding('utf8');
      socket.on('connect', __bind(function() {
        return socket.write("220 " + this.host + " Postmaster " + version + "\n");
      }, this));
      buffer = '';
      state = {
        state: STATES["default"],
        email: this.newEmail()
      };
      return socket.on('data', __bind(function(data) {
        var lines;
        lines = (buffer + data).split("\n");
        buffer = lines.pop();
        return lines.forEach(__bind(function(line, index) {
          return this.handler(socket, line, state);
        }, this));
      }, this));
    }, this));
  }
  Server.prototype.handler = function(socket, line, state) {
    var STATES, token;
    STATES = Server.STATES;
    token = state.state === STATES["default"] ? this.parser.parseLine(line) : this.parser.dataCollection();
    if (token.meaning === 'data-collection' && state.state === STATES.data && line === "") {
      state.state = STATES.possibly_end_data;
    } else if (token.meaning === 'data-collection' && state.state === STATES.possibly_end_data && line === ".") {
      state.state = STATES["default"];
      state.email.body = state.email.body.substring(0, state.email.body.length - 2);
      return socket.write("250 Successsfully saved message (#1)\n");
    } else if (state.state === STATES.data || state.state === STATES.possibly_end_data) {
      state.state = STATES.data;
    } else {
      state.state = STATES["default"];
    }
    if (token.meaning === 'hello') {
      return socket.write("250 Hello " + token.args.domain + ", nice to meet you\n");
    } else if (token.meaning === 'from') {
      state.email = this.newEmail();
      state.email.from = token.args.email;
      return socket.write("250 OK\n");
    } else if (token.meaning === 'to') {
      state.email.to.push(token.args.email);
      return socket.write("250 OK\n");
    } else if (token.meaning === 'data-start') {
      state.state = STATES.data;
      return socket.write("354 OK\n");
    } else if (token.meaning === 'data-collection') {
      if (line === "") {
        return state.email.body += "\n";
      } else {
        return state.email.body += line + "\n";
      }
    } else if (token.meaning === 'ping') {
      return socket.write("250 OK\n");
    } else if (token.meaning === 'reset') {
      state.email = this.newEmail();
      return socket.write("250 OK\n");
    } else if (token.meaning === 'quit') {
      return socket.end();
    } else if (token.meaning === 'info') {
      socket.write("214 Postmaster is a fake SMTP server used for testing.\n");
      return socket.write("214 For more, please visit https://github.com/jamierumbelow/postmaster\n");
    } else if (token.meaning === 'wtf') {
      return socket.write("502 Command Not Implemented\n");
    } else {
      return socket.write("500 Syntax Error\n");
    }
  };
  Server.prototype.newEmail = function() {
    return {
      from: '',
      to: [],
      body: ''
    };
  };
  Server.prototype.createServer = function() {
    return net.createServer();
  };
  Server.prototype.close = function() {
    return this.server.close();
  };
  return Server;
})();