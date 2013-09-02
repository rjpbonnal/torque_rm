#!/usr/bin/env ruby -Ilib

require 'sinatra'
require 'torque_rm'

get '/' do
  'Welcome to our gorgeous TORQUE/PBS web interface.'
end


get '/qstat' do
   TORQUE::Qstat.new.display
end