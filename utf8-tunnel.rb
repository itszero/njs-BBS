#!/usr/bin/ruby -w
require 'socket'
require 'iconv'

STDOUT.sync = true

server = TCPServer.open(7788)
loop do
  Thread.start(server.accept) do |client|
    client.write "Connecting to ptt.cc...\n"

if ENV['TESTRUN']
    client.write Iconv.iconv('utf-8//ignore', 'big5', File.read("ptt.log"))
    loop do
      client.close if client.gets == "bye"
      return
    end
end

    remote = TCPSocket.open(ARGV[0] || "ptt.cc", ARGV[1] || 23)
    tmp = 0
    loop do
      r, w, e = IO.select([client, remote], nil, nil, 0)
      (r || []).each do |f|
        if f == remote
          c = remote.getc
          if (c > 128) && (tmp == 0)
            tmp = c
            next
          end
          if tmp != 0
            str = tmp.chr + c.chr
            begin
              client.write Iconv.iconv('utf-8//ignore', 'big5', str)
              tmp = 0
            rescue
              client.write tmp.chr
              tmp = c
            end
          else
            client.write c.chr
          end
        else
          c = client.getc
          remote.write c.chr
        end
      end
    end
  end
end   
