require 'rye'
module TORQUE
  @@qcommands_path = '/usr/bin'
  @@master = nil
  def self.server=(hostname=nil)
  	if hostname.nil?
  		@@master = Rye.shell
  	else
  		@@master = Rye::Box.new(hostname)
  	end
  end

  def self.server
  	@@master
  end

  def self.qcommands_path=(path)
  	@@qcommands_path = path
  	%w(qstat qsub qdel).each do |command|
  	  Rye::Cmd.remove_command command if Rye::Cmd.can? command
  	  Rye::Cmd.add_command command, File.join(qcommands_path,'qstat')
  	end
  end

  def self.qcommands_path
  	@@qcommands_path
  end
end