require 'date'

module TORQUE
  class Qstat
    Job = Struct.new(:job_id, :job_name, :job_owner, :resources_used_cput, :resources_used_mem, :resources_used_vmem,
           :resources_used_walltime, :job_state, :queue, :server, :checkpoint, :ctime, :error_path, :exec_host,
           :exec_port, :hold_types, :join_path, :keep_files, :mail_points, :mail_users, :mtime, :output_path,
           :priority, :qtime, :rerunable, :resource_list, :session_id,
           :shell_path_list, :variable_list, :etime, :exit_status, :submit_args, :start_time,
           :start_count, :fault_tolerant, :comp_time, :job_radix, :total_runtime, :submit_host) do
      #add here your custom method for Qstat::Job
      def is_runnig?
        job_state == 'R'
      end
      alias running? is_runnig?

      def is_completed?
        job_state == 'C'
      end
      alias completed? is_completed?

      def is_exited?
        job_state == 'E'
      end
      alias exited? is_exited?

      def is_queued?
        job_state == 'Q'
      end
      alias queued? is_queued?
      alias is_in_queue? is_queued?

      def time
				return (resources_used_walltime) ? resources_used_walltime : "-"
      end

      def memory
        resources_used_mem ? (resources_used_mem.split("kb").first.to_f/1000).round(1) : "0"
      end

      def node 
        exec_host ? exec_host.split("+").map {|n| n.split(".").first}.uniq.join(",") : "-"
      end

			def procs
				resource_list.each do |r|
					resource = r[:resource]
					if resource[:name] == "ncpus"
						return resource[:value]
					elsif resource[:name] == "nodes"
						return resource[:value].split("ppn=")[-1]
					end
				end
				return "-"
			end
    end

    class Parser < Parslet::Parser
  rule(:newline)          { match('\n').repeat(1) }
  rule(:space)            { match('\s').repeat }
  rule(:space?)           { space.maybe }
  rule(:tab)              { match('\t').repeat(1) }
  rule(:newline?)         { newline.maybe }
  rule(:value)            { match('[a-zA-Z0-9\.\_\@\/\+ \,\-:=]').repeat }
  rule(:qstat)            { job_id.repeat }
  rule(:resource_list_name)    { str("Resource_List") >> str(".") >> (match('[a-zA-Z]').repeat(1).as(:string)).as(:name) }
  rule(:split_assignment) { (space >> str("=") >> space).repeat(1) }
  root(:qstat)

  rule(:variable_item){ tab >> value >> newline }
  rule(:variable_items) { variable_item.repeat }
  rule(:variable_list_items) { value >> newline >> variable_items.maybe}


  rule(:job_id)                  {(str("Job Id:") >> space >> value.as(:string)).as(:job_id) >> newline? >> fields.maybe >> newline? }
  rule(:job_name)                {(space >> str("Job_Name = ") >> value.as(:string) >> newline).as(:job_name)}
  rule(:job_owner)               {(space >> str("Job_Owner = ") >> value.as(:string) >> newline).as(:job_owner)}
  rule(:resources_used_cput)     {(space >> str("resources_used.cput = ") >> value.as(:string) >> newline).as(:resources_used_cput)}
 	rule(:resources_used_mem)      {(space >> str("resources_used.mem = ") >> value.as(:string) >> newline).as(:resources_used_mem)}
 	rule(:resources_used_vmem)     {(space >> str("resources_used.vmem = ") >> value.as(:string) >> newline).as(:resources_used_vmem)}
 	rule(:resources_used_walltime) {(space >> str("resources_used.walltime = ") >> value.as(:string) >> newline).as(:resources_used_walltime)}
 	rule(:job_state)               {(space >> str("job_state = ") >> value.as(:string) >> newline).as(:job_state)}
 	rule(:queue)                   {(space >> str("queue = ") >> value.as(:string) >> newline).as(:queue)}
 	rule(:server)                  {(space >> str("server = ") >> value.as(:string) >> newline).as(:server)}
 	rule(:checkpoint)              {(space >> str("Checkpoint = ") >> value.as(:string) >> newline).as(:checkpoint)}
 	rule(:ctime)                   {(space >> str("ctime = ") >> value.as(:datetime) >> newline).as(:ctime)}
 	rule(:error_path)              {(space >> str("Error_Path = ") >> value.as(:string) >> newline).as(:error_path)}
 	rule(:exec_host)               {(space >> str("exec_host = ") >> value.as(:string) >> newline).as(:exec_host)}
 	rule(:exec_port)               {(space >> str("exec_port = ") >> value.as(:string) >> newline).as(:exec_port)}
 	rule(:hold_types)              {(space >> str("Hold_Types = ") >> value.as(:string) >> newline).as(:hold_types)}
 	rule(:join_path)               {(space >> str("Join_Path = ") >> value.as(:string) >> newline).as(:join_path)}
 	rule(:keep_files)              {(space >> str("Keep_Files = ") >> value.as(:string) >> newline).as(:keep_files)}
 	rule(:mail_points)             {(space >> str("Mail_Points = ") >> value.as(:string) >> newline).as(:mail_points)}
 	rule(:mail_users)              {(space >> str("Mail_Users = ") >> value.as(:string) >> newline).as(:mail_users)}
 	rule(:mail_users?)             {mail_users.maybe }
 	rule(:mtime)                   {(space >> str("mtime = ") >> value.as(:datetime) >> newline).as(:mtime)}
 	rule(:output_path)             {(space >> str("Output_Path = ") >> value.as(:string) >> newline).as(:output_path)}
 	rule(:priority)                {(space >> str("Priority = ") >> value.as(:integer) >> newline).as(:priority)}
 	rule(:qtime)                   {(space >> str("qtime = ") >> value.as(:datetime) >> newline).as(:qtime)}
 	rule(:rerunable)               {(space >> str("Rerunable = ") >> value.as(:boolean) >> newline).as(:rerunable)}

  rule(:resource)                {(space >> resource_list_name >> str(" = ") >> (value.as(:string)).as(:value) >> newline).as(:resource)}
  rule(:resource_list)           { resource.repeat.as(:resource_list)}

 	rule(:session_id)              {(space >> str("session_id = ") >> value.as(:integer) >> newline).as(:session_id)}
 	rule(:shell_path_list)         {(space >> str("Shell_Path_List = ") >> value.as(:string) >> newline).as(:shell_path_list)}
  rule(:variable_list)           {(space >> str("Variable_List = ") >> variable_list_items.as(:string) >> newline.maybe).as(:variable_list)}
 	rule(:etime)                   {(space >> str("etime = ") >> value.as(:datetime) >> newline).as(:etime)}
  rule(:exit_status)             {(space >> str("exit_status = ") >> value.as(:string) >> newline).as(:exit_status)}
 	rule(:submit_args)             {(space >> str("submit_args = ") >> value.as(:string) >> newline).as(:submit_args)}
 	rule(:start_time)              {(space >> str("start_time = ") >> value.as(:datetime) >> newline).as(:start_time)}
 	rule(:start_count)             {(space >> str("start_count = ") >> value.as(:integer) >> newline).as(:start_count)}
 	rule(:fault_tolerant)          {(space >> str("fault_tolerant = ") >> value.as(:boolean) >> newline).as(:fault_tolerant)}
  rule(:comp_time)               {(space >> str("comp_time = ") >> value.as(:datetime) >> newline).as(:comp_time)}
 	rule(:job_radix)               {(space >> str("job_radix = ") >> value.as(:string) >> newline).as(:job_radix)}
  rule(:total_runtime)           {(space >> str("total_runtime = ") >> value.as(:string) >> newline).as(:total_runtime)}
 	rule(:submit_host)             {(space >> str("submit_host = ") >> value.as(:string) >> newline?).as(:submit_host)}

# a lot of maybe, maybe everything

  rule(:fields) { job_name.maybe >> job_owner.maybe >> resources_used_cput.maybe >> resources_used_mem.maybe >> 
      resources_used_vmem.maybe >> resources_used_walltime.maybe >> job_state.maybe >> queue.maybe  >> server.maybe >> 
      checkpoint.maybe >> ctime.maybe >> error_path.maybe >> exec_host.maybe >> exec_port.maybe >> hold_types.maybe  >> join_path.maybe >>
      keep_files.maybe >> mail_points.maybe >> mail_users? >> mtime.maybe >> output_path.maybe >> tab.maybe >> newline? >>
        priority.maybe >> qtime.maybe >> rerunable.maybe >> resource_list.maybe >>
        session_id.maybe >> shell_path_list.maybe >> variable_list >> etime.maybe >> exit_status.maybe >> submit_args.maybe >>
        start_time .maybe>> start_count.maybe >>fault_tolerant.maybe >> comp_time.maybe >> job_radix.maybe >> total_runtime.maybe >> submit_host.maybe >> newline?
        }


    end #Parser

    class Trans < Parslet::Transform
      rule(:datetime => simple(:datetime)) {DateTime.parse(datetime)}
      rule(:string => simple(:string))     {String(string)}
      rule(:integer => simple(:integer))   {Integer(integer)}
      rule(:boolean => simple(:boolean))   {String(boolean) == "True"}
    end #Trans


    def initialize
        @parser = Parser.new
        @transformer = Trans.new
        @last_query = nil #cache last query, it can be useful to generate some kind of statistics ? 
    end #initialize
 
    # hash can contain keys:
    # type = :raw just print a string
    # job_id = job.id it will print info only about the specified job
    # job_ids = ["1.server", "2.server", "3.server"] get an array for requested jobs
    def query(hash={})
        result = TORQUE.server.qstat("-f")
        results = nil
        if hash[:type] == :raw
          result.to_s
        else

          begin
            results = @transformer.apply(@parser.parse(result.to_s.gsub(/\n\t/,'')))
          rescue Parslet::ParseFailed => failure
            puts failure.cause.ascii_tree
          end

          results = [] if results.is_a?(String) && results.empty?
          if hash.key? :job_ids
            if hash[:job_ids].is_a? Array
              results.select! {|j| (hash[:job_ids].include?(j[:job_id].to_s) || hash[:job_ids].include?(j[:job_id].to_s.split(".").first))}
            elsif hash[:job_ids].is_a? String
              warn "To be implemented for String object."
            else
              warm "To be implemented for #{hash[:job_ids].class}"
            end
          else
            results
          end
        end

        @last_query = from_parselet_to_jobs(results)
    end #query

    def display(hash={})
      query(hash)
      print_jobs_table(@last_query)
    end

private

    def from_parselet_to_jobs(results)
        results.map do |raw_job|
          job = Job.new
           raw_job.each_pair do |key, value|
              job.send "#{key}=", value
          end #each pair
          job
        end #each_job
    end

    def print_jobs_table(jobs_info)  
			rows = []
      head = ["Job ID","Job Name","Node(s)","Procs (per node)","Mem Used","Run Time","Queue","Status"]
      headings = head.map {|h| {:value => h, :alignment => :center}}
      if jobs_info.empty?
        print "\n\nNo Running jobs for user: ".light_red+"#{`whoami`}".green+"\n\n"
      	exit
			else
        jobs_info.each do |job|
          line = [job.job_id.split(".").first,job.job_name,job.node,job.procs,"#{job.memory} mb","#{job.time}",job.queue,job.job_state]
          if job.completed?
            line[-1] = "Completed"; rows << line.map {|l| l.underline}
          elsif job.queued?
            line[-1] = "Queued"; rows << line.map {|l| l.light_blue}
          elsif job.running?
            line[-1] = "Running"; rows << line.map {|l| l.green}
          elsif job.exited?
            line[-1] = "Exiting"; rows << line.map {|l| l.green.blink}
          else
            rows << line.map {|l| l.red.blink}
          end  
        end
        print "\nSummary of submitted jobs for user: ".light_blue+"#{jobs_info.first[:job_owner].split("@").first.green}\n\n"
        table = Terminal::Table.new :headings => headings, :rows => rows
      	Range.new(0,table.number_of_columns-1).to_a.each {|c| table.align_column(c,:center) } # set all columns alignment to :center
				puts table
      end

    end

  end # Qstat
end # TORQUE
