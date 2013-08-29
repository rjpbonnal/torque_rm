module TORQUE
  class Qstat
    class Parser < Parslet::Parser
  	rule(:newline) {match('\n').repeat(1)}
  	rule(:space) {match('\s').repeat}
  	rule(:space?) {space.maybe}
    rule(:tab) {match('\t').repeat(1)}
  	rule(:newline?) {newline.maybe}
  	rule(:value) { match('[a-zA-Z0-9\.\_\@\/\+ \,\-:=]').repeat}
  	rule(:qstat) { job_id.repeat }
    root(:qstat)

    rule(:variable_item){ tab >> value >> newline }
    rule(:variable_items) { variable_item.repeat }
    rule(:variable_list_items) { value >> newline >> variable_items.maybe}


  	rule(:job_id) { str("Job Id:") >> space >> value.as(:job_id) >> newline? >> fields.maybe >> newline? }
  	rule(:job_name) {space >> str("Job_Name = ") >> value.as(:job_name) >> newline}
  	rule(:job_owner) {space >> str("Job_Owner = ") >> value.as(:job_owner) >> newline}
  	rule(:resources_used_cput) {space >> str("resources_used.cput = ") >> value.as(:resources_used_cput) >> newline}
 	rule(:resources_used_mem) {space >> str("resources_used.mem = ") >> value.as(:resources_used_mem) >> newline}
 	rule(:resources_used_vmem) {space >> str("resources_used.vmem = ") >> value.as(:resources_used_vmem) >> newline}
 	rule(:resources_used_walltime) {space >> str("resources_used.walltime = ") >> value.as(:resources_used_walltime) >> newline}
 	rule(:job_state) {space >> str("job_state = ") >> value.as(:job_state) >> newline}
 	rule(:queue) {space >> str("queue = ") >> value.as(:queue) >> newline}
 	rule(:server) {space >> str("server = ") >> value.as(:server) >> newline}
 	rule(:checkpoint) {space >> str("Checkpoint = ") >> value.as(:checkpoint) >> newline}
 	rule(:ctime) {space >> str("ctime = ") >> value.as(:ctime) >> newline}
 	rule(:error_path) {space >> str("Error_Path = ") >> value.as(:error_path) >> newline}
 	rule(:exec_host) {space >> str("exec_host = ") >> value.as(:exec_host) >> newline}
 	rule(:exec_port) {space >> str("exec_port = ") >> value.as(:exec_port) >> newline}
 	rule(:hold_types) {space >> str("Hold_Types = ") >> value.as(:hold_types) >> newline}
 	rule(:join_path) {space >> str("Join_Path = ") >> value.as(:join_path) >> newline}
 	rule(:keep_files) {space >> str("Keep_Files = ") >> value.as(:keep_files) >> newline}
 	rule(:mail_points) {space >> str("Mail_Points = ") >> value.as(:mail_points) >> newline}
 	rule(:mail_users) {space >> str("Mail_Users = ") >> value.as(:mail_users) >> newline}
 	rule(:mail_users?) {mail_users.maybe }
 	rule(:mtime) {space >> str("mtime = ") >> value.as(:mtime) >> newline}
 	rule(:output_path) {space >> str("Output_Path = ") >> value.as(:output_path) >> newline}
 	rule(:priority) {space >> str("Priority = ") >> value.as(:priority) >> newline}
 	rule(:qtime) {space >> str("qtime = ") >> value.as(:qtime) >> newline}
 	rule(:rerunable) {space >> str("Rerunable = ") >> value.as(:rerunable) >> newline}
 	rule(:resource_list_nodect) {space >> str("Resource_List.nodect = ") >> value.as(:resource_list_nodect) >> newline}
 	rule(:resource_list_nodes) {space >> str("Resource_List.nodes = ") >> value.as(:resource_list_nodes) >> newline}
 	rule(:session_id) {space >> str("session_id = ") >> value.as(:session_id) >> newline}
 	rule(:shell_path_list) {space >> str("Shell_Path_List = ") >> value.as(:shell_path_list) >> newline}
 	#rule(:variable_list) {space >> str("Variable_List = ") >> value.as(:variable_list) >> newline}
    rule(:variable_list) {space >> str("Variable_List = ") >> variable_list_items.as(:variable_list) >> newline.maybe}
 	rule(:etime) {space >> str("etime = ") >> value.as(:etime) >> newline}
    rule(:exit_status){ space >> str("exit_status = ") >> value.as(:exit_status) >> newline}
 	rule(:submit_args) {space >> str("submit_args = ") >> value.as(:submit_args) >> newline}
 	rule(:start_time) {space >> str("start_time = ") >> value.as(:start_time) >> newline}
 	rule(:start_count) {space >> str("start_count = ") >> value.as(:start_count) >> newline}
 	rule(:fault_tolerant) {space >> str("fault_tolerant = ") >> value.as(:fault_tolerant) >> newline}
 	rule(:job_radix) {space >> str("job_radix = ") >> value.as(:job_radix) >> newline}
    rule(:total_runtime) {space >> str("total_runtime = ") >> value.as(:total_runtime) >> newline}
 	rule(:submit_host) {space >> str("submit_host = ") >> value.as(:submit_host) >> newline?}

# a lot of maybe, maybe everything
  	rule(:fields) { job_name.maybe >> job_owner.maybe >> resources_used_cput.maybe >> resources_used_mem.maybe >> 
  		resources_used_vmem.maybe >> resources_used_walltime.maybe >> job_state.maybe >> queue.maybe  >> server.maybe >> 
  		checkpoint.maybe >> ctime.maybe >> error_path.maybe >> exec_host.maybe >> exec_port.maybe >> hold_types.maybe  >> join_path.maybe >>
  		keep_files.maybe >> mail_points.maybe >> mail_users? >> mtime.maybe >> output_path.maybe >> tab.maybe >> newline? >>
        priority.maybe >> qtime.maybe >> rerunable.maybe >> resource_list_nodect.maybe >> resource_list_nodes.maybe >>
        session_id.maybe >> shell_path_list.maybe >> variable_list >> etime.maybe >> exit_status.maybe >> submit_args.maybe >>
        start_time .maybe>> start_count.maybe >> fault_tolerant.maybe >> job_radix.maybe >> total_runtime.maybe >> submit_host.maybe >> newline?
        }


#original 
    # rule(:fields) { job_name >> job_owner >> resources_used_cput.maybe >> resources_used_mem.maybe >> 
    #     resources_used_vmem.maybe >> resources_used_walltime.maybe >> job_state >> queue  >> server >> 
    #     checkpoint >> ctime >> error_path >> exec_host.maybe >> exec_port.maybe >> hold_types  >> join_path >>
    #     keep_files >> mail_points >> mail_users? >> mtime >> output_path >> tab.maybe >> newline? >>
    #     priority >> qtime >> rerunable >> resource_list_nodect.maybe >> resource_list_nodes.maybe >>
    #     session_id.maybe >> shell_path_list.maybe >> variable_list >> etime >> submit_args.maybe >>
    #     start_time .maybe>> start_count.maybe >> fault_tolerant >> job_radix.maybe >> submit_host >> newline?
    #     }

    end #Parser

    def initialize
        @parser = Parser.new
    end

    # hash can contain keys:
    # type = :raw just print a string
    # job_id = job.id it will print info only about the specified job
    # job_ids = ["1.server", "2.server", "3.server"] get an array for requested jobs
    def query(hash={})
        result = TORQUE.server.qstat("-f")
        if hash[:type] == :raw
          result.to_s
        else
          results = @parser.parse(result.to_s.gsub(/\n\t/,''))
          if hash.key? :job_id
            results.select{|result| result[:job_id] == hash[:job_id]}
          elsif hash.key? :job_ids
            if hash[:job_ids].is_a? Array
              results.select{|result| hash[:job_ids].include?(result[:job_id])}
            elsif hash[:job_ids].is_a? String
              warn "To be implemented for String object."
            else
              warm "To be implemented for #{hash[:job_ids].class}"
            end
          else
            results
          end
        end
    end

  end # Qstat
end # TORQUE
