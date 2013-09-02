#!/usr/bin/env ruby -Ilib

require 'haml'
require 'sinatra'
require 'torque_rm'
require 'sinatra/twitter-bootstrap'
require "#{File.dirname(__FILE__)}/../web/helpers/qstat.rb"


register Sinatra::Twitter::Bootstrap::Assets

set :root, File.join(File.dirname(__FILE__),"..","web")


helpers TORQUE::Qstat::Sinatra::Helpers

get '/' do
  'Welcome to our gorgeous TORQUE/PBS web interface.'
end


get '/qstat' do
   jobs = TORQUE::Qstat.new.query
   haml :qstat, :format => :html5, :locals => {:jobs => jobs}
end


__END__

@@ layout
%html
  %head
    = bootstrap_assets
  %body
    - container :fluid do
      - row do
        - span8 do
          = yield
        - span4 :offset => 4 do
          %p hello world