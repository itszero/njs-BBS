var net = require('net'),
    http = require('http'),
    io = require('./socket.io-node'),
    pb = require('./node-paperboy'),
    path = require('path');

var httpServer = http.createServer(function(req, res) {
  pb.deliver(path.join(path.dirname(__filename), 'web'), req, res);
});
httpServer.listen(9000, '0.0.0.0');

var webSocketServer = io.listen(httpServer);
webSocketServer.on('connection', function(client) {
  console.log("Opening connection to PTT.cc");
  var ptt = net.createConnection(7788, 'localhost');
  // var ptt = net.createConnection(23, 'towel.blinkenlights.nl');
  ptt.setEncoding('utf8');
  ptt.on('data', function(data) {
    client.send({'type': 'data', 'data': data});
  });
  client.on('message', function(msg, client) {
    if (msg.type == 'key')
    {
      ptt.write(msg.data);
    }
  });
  client.on('disconnect', function() { ptt.end(); console.log("Client disconnected, remote conn. closed"); });
});

console.log("BBSBridge running at http://0.0.0.0:9000/");
