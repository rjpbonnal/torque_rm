#!/usr/bin/env ruby -Ilib

require 'sinatra'
require 'torque_rm'

set :root, File.join(File.dirname(__FILE__),"..","web")

get '/' do
  'Welcome to our gorgeous TORQUE/PBS web interface.'
end


get '/qstat' do
   jobs = TORQUE::Qstat.new.query
   haml :qstat, :format => :html5, :locals => {:jobs => jobs}
end