# require 'ostruct'
module TORQUE


# q=PBS::Qsub.new name: "Mapping", m: "abe", l: "nodes=1:ppn=4", d: '/mnt/bio/ngs/pbs', e: '/mnt/bio/ngs/pbs', shell: '/bin/bash', o: '/mnt/bio/ngs/pbs';


# [-a date_time] [-A account_string] [-b secs] [-c checkpoint_options]
#        [-C directive_prefix] [-d path] [-D path] [-e path] [-f] [-h]
#        [-I ] [-j  join ] [-k   keep ] [-l resource_list ]
#        [-m  mail_options] [-M  user_list] [-N  name] [-o path]
#        [-p  priority] [-P user[:group]] [-q  destination] [-r c] [-S  path_list]
#        [-t  array_request] [-u  user_list]  
#        [-v  variable_list] [-V ] [-W additional_attributes] [-X] [-z] [script]

  
  class Qsub
  	attr_accessor :a, :A,:b,:c,:C,:d,:D,:e,:f,:h,:I,:j,:k,:l
  	attr_accessor :m,:M,:N,:o,:p,:P,:q,:r,:S,:t,:u,:v,:V,:W,:X,:z, :script
  	attr_accessor :walltime,:gres,:ppn, :procs
    attr_accessor :id
  	attr_writer :nodes

    # def script(*args)
    #   if args.size == 1
    #     @script =  args[0]
    #   else
    #     @script
    #   end
    # end


    alias :cpus :ppn
    alias :cpus= :ppn=
    alias :shell :S
    alias :shell= :S=
    alias :name :N
    alias :name= :N=
    alias :queue :q
    alias :queue= :q=
    alias :account :A
    alias :account= :A=
    alias :when :a
    alias :when= :a=
    alias :checkpoint :c
    alias :checkpoint= :c=
    alias :wd :d
    alias :wd= :d=
    alias :working_directory :d
    alias :working_directory= :d=
    alias :root_directory :D
    alias :root_directory= :D=
    alias :email :M
    alias :email= :M=
    alias :stderr :e
    alias :stderr= :e=
    alias :stdout :o
    alias :stdout= :o=
    alias :run_as_user :P
    alias :run_as_user= :P=
    alias :rerunnable :r
    alias :rerunnable= :r=
    alias :user_list :u
    alias :user_list= :u=
    alias :variable_list :v
    alias :variable_list= :v=
    alias :exports :V
    alias :exports= :V=
    alias :additional_attributes :X
    alias :additional_attributes= :X=

  	def initialize(opts={}, &block)
      @id = nil # configure when the job is submitted
  		@a =opts[:a] || opts[:date_time]
  		@A = opts[:A] || opts[:account]
  		@b = opts[:b]
  		@c = validate_checkpoint(opts[:c] || opts[:checkpoint])
  		@C = opts[:C] || opts[:directive_prefix]
  		@d = opts[:d] || opts[:working_directory] # PBS_O_INITDIR
  		@D = opts[:D] || opts[:root_directory] # PBS_O_ROOTDIR
  		@e = opts[:e] || opts[:stderr] # [hostname:]path_name
  		@f = opts[:f] || opts[:fault_tolerant] # boolean
  		@h = opts[:h] || opts[:user_hold] # boolean
  		@I = opts[:I] || opts[:interactive]
  		@j = opts[:j] || opts[:join_stdout_stderr]  		
  		@k = validate_keep(opts) # check manual because I'm not going to implement this now.
  		@l = opts[:l]
  		@nodes = opts[:nodes]
  		@walltime = opts[:walltime]
  		@gres = opts[:gres]
  		@ppn = opts[:ppn]
  		@procs = opts[:procs]
  		@m = validate_mail_options(opts)
  		@M = opts[:M] || opts[:email]
  		@N = opts[:N] || opts[:name]
  		@o = opts[:o] || opts[:stdout] # [hostname:]path_name
  		@p = validate_priority(opts) # between -1024, +1023
  		@P = opts[:P] || opts[:root_as_user]
  		@q = opts[:q] || opts[:queue]
  		@r = opts[:r] || opts[:rerunnable] # y|n
  		@S = opts[:S] || opts[:shell]
  		@t = opts[:t] || opts[:array_request]
  		@u = opts[:u] || opts[:user_list]
  		@v = opts[:v] || opts[:variable_list]
  		@V = opts[:V] || opts[:exports] #this is just a boolean 
  		@W = opts[:W] || opts[:additional_attributes] # to DEVELOP, chaining jobs together.
  		@X = opts[:X] || opts[:X_forwardning] # boolean
  		@z = opts[:z] || opts[:no_jobid]
  		@script = opts[:script]
      if block_given?
        if block.arity == 1
          yield self
        end
      end

    end # initialize

    def config(&block)
      if block_given?
        if block.arity == 1
          yield self
        else
          instance_eval &block
          self
        end
      end
  	end # config

  	def l
  		data=[@l, nodes, @walltime, @gres].select{|x| x}.join(',')
      if data.empty?
        nil
      else
        data
      end
  	end

  	def nodes
  		str_nodes = if @nodes
  			           @nodes
  		            elsif ppn
  			           "nodes=1"
  		            end

  		if ppn
  			str_nodes << ':' << "ppn=#{ppn}"
  		elsif procs
  			str_nodes << '+' << "procs=#{procs}"
  		end
  				
  	end


  	def to_s
  	  pbs_script = ""
  	  [:a, :A,:b,:c,:C,:d,:D,:e,:f,:h,:I,:j,:k,:l,:m,:M,:N,:o,:p,:P,:q,:r,:S,:t,:u,:v,:V,:W,:X,:z].each do |option|
  	  	value = send(option)
  	  	pbs_script << "#PBS -#{option} #{value}\n" unless value.nil?
  	  end
  	  pbs_script << "#{script}" unless script.nil?
  	  if script.nil?
  	  	warn("You are converting this qsub job into a script without a real code.")
  	  end
  	  pbs_script
    end

    # Create a qsub job on the remote server and then submits it
    # return the job_id from qsub and set it as a job variable.
    # :dry => true will only transfer the file to the destination server and will not submit the job to the scheduler
    #    the job object will not have an id associated. 
    def submit(opts={dry: false})
      TORQUE.server.file_upload StringIO.new(to_s), script_absolute_filename
      @id = TORQUE.server.qsub(script_absolute_filename).first unless opts[:dry] == true
    end

    # get the stats for this job
    def stat
      if id.nil? 
        warn("No job submitted")
      else
        @qstat = @qstat || TORQUE::Qstat.new
        @qstat.query(job_id: id)
      end
    end


    # delete this job from the queue
    def rm
      if id.nil? 
        warn("No job submitted")
      else
        TORQUE::Qdel.rm(id)
      end
    end      







#   	def to_s

#   		<<-TOS
# #!/bin/bash
# #PBS -S /bin/bash
# #PBS -m abe
# #PBS -N #{task.name}
# #PBS -l nodes=1:ppn=#{task.cpus}
# #PBS -d #{task.wd}
# #PBS -e #{task.wd}
# #PBS -o #{task.wd}
# #{task.command}
# TOS
#   	end # to_s

  	private 

    # get the current work directory.
    # if root_directory is defined it will get precedence on working_directory
    # if root or working directories are not defined the user home directory is
    # the default directory
    def script_dir
      root_directory || working_directory || '~'
    end

    def script_filename
      "#{name}.pbs"
    end

    def script_absolute_filename
      File.join(script_dir,script_filename)
    end


	# Defines the options that will apply to the job. If the job executes upon a host which does not support checkpoint, these options will be ignored.
	# Valid checkpoint options are:

	# none - No checkpointing is to be performed.
	# enabled - Specify that checkpointing is allowed but must be explicitly invoked by either the qhold or qchkpt commands.
	# shutdown - Specify that checkpointing is to be done on a job at pbs_mom shutdown.
	# periodic - Specify that periodic checkpointing is enabled. The default interval is 10 minutes and can be changed by the $checkpoint_interval option in the mom config file or by specifying an interval when the job is submitted
	# interval=minutes - Checkpointing is to be performed at an interval of minutes, which is the integer number of minutes of wall time used by the job. This value must be greater than zero.
	# depth=number - Specify a number (depth) of checkpoint images to be kept in the checkpoint directory.
	# dir=path - Specify a checkpoint directory (default is /var/spool/torque/checkpoint).
  	def validate_checkpoint(value)
  		if value.nil? || value=~/none|enabled|shutdown|periodic|interval|depth|dir/
  			value
  		else
  			raise "#{value} is not a valid option for checkpoint"
  		end
  	end

  	def validate_mail_options(opts)
  		value = opts[:m] || [opts[:send_on_abort], opts[:send_on_begin], opts[:send_on_end]].select{|item| item}.join
      value.empty? ? nil : value 
  	end

    def validate_keep(opts)
    	if (value = opts[:k] || opts[:keep])
    		if value =~/eo|oe|e|o|n/
    		  value
    		else
    			raise "#{value} is not a valid option for keep"
    	    end
    	end
    end

    def validate_priority(opts)
    	value = opts[:p] || opts[:priority]
    	if value.nil? || (-1024..1023).include?(value)
    		value
    	else
    		raise "#{value} is out of range for priority, stay in between [-1024, +1023]"
    	end
    end
    # Check if the hash contains valid PBS options.
    # If a key is not a valid pbs option a warning message is raise but the key is ket in the ostruct
  	# def validate_pbs_options(hash=nil)
  	# end

    def fields
	    instance_variable_get("@table").keys
    end

  end # Job
end # PBS


# 	require 'bio-ngs'
# require 'ostruct'


# # This script can run only in a directory where data are trimmed.
# # Parameter: ensembl release number
# #            the full path directory of a run

# release =  ARGV[0]
# run = ARGV[1]
# path = ENV['ENSEMBL_STORAGE_PATH']
# ensembl_release = "Homo_sapiens.GRCh37.#{release}"
# index = "#{path}/release-#{release}/fasta/homo_sapiens/dna/#{ensembl_release}"
# transcriptome_index = "#{path}/release-#{release}/gtf/homo_sapiens/transcriptome_data/#{ensembl_release}/known"
# map_type = 'map_idx_e'
# cpus = 20

#     tasks = []
    
#     Bio::Ngs::Illumina.build(run).each do |project_name, project|
#       project.each_sample do |sample_name, sample|
# #        puts "#{run} #{project_name} #{sample_name}"
#         tasks << task = OpenStruct.new(command:"", type:"", name:"", wd:"", cpus:"")
#         task.type = map_type
#         task.cpus = cpus
#         task.wd = File.join(run,"Project_#{project_name}","Sample_#{sample_name}")
#         task.name = "#{task.type}_#{sample_name}"
#         task.command = <<-QSUB
# tophat -r 400 -p #{cpus} -o #{map_type} --transcriptome-index=#{transcriptome_index} #{index} #{sample.path}_R1.trimmed.fastq.gz #{sample.path}_R2.trimmed.fastq.gz
# samtools flagstat #{map_type}/accepted_hits.bam > #{map_type}/flagstat.txt
# QSUB

#       end unless project_name=~/Undetermined/ 
#     end


# #create PBS command
# tasks.each do |task|
#   File.open(File.join(task.wd,"#{task.name}.pbs"), 'w') do |file|
#     file.write <<-EOS
# #!/bin/bash
# #PBS -S /bin/bash
# #PBS -m abe
# #PBS -N #{task.name}
# #PBS -l nodes=1:ppn=#{task.cpus}
# #PBS -d #{task.wd}
# #PBS -e #{task.wd}
# #PBS -o #{task.wd}
# #{task.command}
# EOS

#   end
# end
