require 'rye'
require 'etc'

module TORQUE
  @@username = Etc.getlogin
	@@qcommands_path = '/usr/bin'
  @@master = Rye::Box.new("localhost")
  @@conf = {}
  def self.server=(hostname)
  	if hostname
  		@@master = Rye::Box.new(hostname, @@conf)
  	end
  end

  def self.server
  	@@master
  end

	def self.username=(username)
		@@username = username
	end

  def self.username
    @@username
  end

  def self.user
    @@username
  end



  def self.qcommands_path=(path)
  	@@qcommands_path = path
  	%w(qstat qsub qdel).each do |command|
  	  Rye::Cmd.remove_command command if Rye::Cmd.can? command
  	  Rye::Cmd.add_command command, File.join(qcommands_path, command)
  	end
  end

  def self.qcommands_path
  	@@qcommands_path
  end

  def self.path
  	self.qcommands_path
  end

  def self.read_config(file)
  	if File.exists?(file)
  	  conf = YAML::load( File.open( file) )
      @@conf = conf.dup
      @@conf.delete(:hostname)
      @@conf.delete(:path)
  	  self.qcommands_path = conf[:path]
    	self.username = conf[:user] unless conf[:user].nil?
      # self.port = conf[:port] unless conf[:port].nil?
      # self.password = conf[:password] unless conf[:password].nil?
  	  self.server = conf[:hostname]
		end
  end

  # Load configuration, default from file in user home with name .toruqe_rm.yaml
  def self.load_config(file=nil)
  	self.read_config File.expand_path(file.nil? ? "~/.torque_rm.yaml" : file)
  	self
  end

  # Save configuration, default in user home with name .toruqe_rm.yaml
  def self.save_config(file=nil)
  	File.write File.expand_path(file.nil? ? "~/.torque_rm.yaml" : file), {hostname: @@master.host, path: @@qcommands_path, user: @@username}.to_yaml
  end

  # Get the host name/ip of the local/remote server user as submitter/interface to PBS
  def self.host
  	self.server.host
  end

  # Get the hostname, this may require an internet connection and fully qualified name
  def self.hostname
  	self.server.hostname
  end

end
