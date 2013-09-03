#!/usr/bin/env ruby -Ilib

require 'haml'
require 'sinatra'
require 'torque_rm'
require 'sinatra/twitter-bootstrap'
require 'sinatra/json'
# require 'ap'
require "#{File.dirname(__FILE__)}/../web/helpers/qstat.rb"


register Sinatra::Twitter::Bootstrap::Assets

set :root, File.join(File.dirname(__FILE__),"..","web")


helpers TORQUE::Qstat::Sinatra::Helpers

get '/' do
  'Welcome to our gorgeous TORQUE/PBS web interface.'.to_json
end


get '/qstat' do
   jobs = TORQUE::Qstat.new.query
   jobs.to_json
   # haml :qstat, :format => :html5, :locals => {:jobs => jobs}
end

get '/qstat/fields' do
  json TORQUE::Qstat::FIELDS
end

get '/qstat/all/:field' do |field|
  if TORQUE::Qstat::FIELDS.include? field
    jobs = TORQUE::Qstat.new.query
    json jobs.map{|job| job[field.to_sym]}
  else
    return status 404
  end
end

get '/qstat/:job_id' do |job_id|
	job = TORQUE::Qstat.new.query job_id: job_id
  # q = TORQUE::Qstat.new
  # p = TORQUE::Qstat::Parser.new
  # t = TORQUE::Qstat::Trans.new

  # s= "Job Id: 2770.deep.space.nine\n    Job_Name = STDIN\n    Job_Owner = johndoe@deep.space.nine\n    resources_used.cput = 00:00:00\n    resources_used.mem = 3148kb\n    resources_used.vmem = 32528kb\n    resources_used.walltime = 00:28:05\n    job_state = R\n    queue = bio\n    server = deep.space.nine\n    Checkpoint = u\n    ctime = Mon Sep  2 18:43:10 2013\n    Error_Path = deep.space.nine:/mnt/bio/ngs/data/home/johndoe/STDIN.e2770\n    exec_host = scrapper/0\n    exec_port = 15003\n    Hold_Types = n\n    Join_Path = n\n    Keep_Files = n\n    Mail_Points = a\n    mtime = Mon Sep  2 18:43:11 2013\n    Output_Path = deep.space.nine:/mnt/bio/ngs/data/home/johndoe/STDIN.o2770\n\t\n    Priority = 0\n    qtime = Mon Sep  2 18:43:10 2013\n    Rerunable = True\n    Resource_List.ncpus = 2\n    Resource_List.nice = 0\n    session_id = 16963\n    Variable_List = PBS_O_QUEUE=bio,PBS_O_HOST=deep.space.nine,\n\tPBS_O_HOME=/mnt/bio/ngs/data/home/johndoe,PBS_O_LANG=it_IT.UTF-8,\n\tPBS_O_LOGNAME=johndoe,\n\tPBS_O_PATH=/mnt/bio/ngs/data/opt/fastx_toolkit/bin:/mnt/bio/ngs/data/\n\topt/bedtools/bin:/mnt/bio/ngs/data/opt/fuseki:/mnt/bio/ngs/data/opt/je\n\tna/bin:/mnt/bio/ngs/data/opt/CASAVA/bin:/mnt/bio/ngs/data/bin/cloaked-\n\thipster/utils:/mnt/bio/ngs/data/bin/cloaked-hipster/utils/ngs/pipeline\n\ts:/mnt/bio/ngs/data/bin/cloaked-hipster/utils/db:/mnt/bio/ngs/data/opt\n\t/trimmomatic:/mnt/bio/ngs/data/opt/PHYLOCSF/hmmer-3.0-linux-intel-x86_\n\t64/binaries:/mnt/bio/ngs/data/opt/PHYLOCSF/mlin-PhyloCSF-983a652/:/mnt\n\t/bio/ngs/data/bin/cloaked-hipster/ncrnapp/PBS_pipeline/:/mnt/bio/ngs/d\n\tata/opt/bowtie-0.12.9:/mnt/bio/ngs/data/opt/bowtie_current:/mnt/bio/ng\n\ts/data/opt/STAR_current:/mnt/bio/ngs/data/opt/RSeQC-2.3.5/RQC/usr/loca\n\tl/bin:/mnt/bio/ngs/data/opt/tophat_current:/mnt/bio/ngs/data/opt/PASA/\n\tscripts:/mnt/bio/ngs/data/opt/PASA/bin:/mnt/bio/ngs/data/opt/fasta/bin\n\t:/mnt/bio/ngs/data/opt/cufflinks:/mnt/bio/ngs/data/opt/samtools:/mnt/b\n\tio/ngs/data/opt/samtools/bcftools:/mnt/bio/ngs/data/opt/samtools/misc:\n\t/mnt/bio/ngs/data/opt/STAR_current/bin:/mnt/bio/ngs/data/opt/gmap/bin:\n\t/mnt/bio/ngs/data/opt/velvet:/mnt/bio/ngs/data/opt/velvet/contrib/colu\n\tmbus_scripts:/opt/blat:/mnt/bio/ngs/data/opt/oases/:/mnt/bio/ngs/data/\n\topt/oases/scripts:/mnt/bio/ngs/data/opt/trinityrnaseq:/mnt/bio/ngs/dat\n\ta/opt/trinityrnaseq/util:/usr/local/bin/:/mnt/bio/ngs/data/home/bonnal\n\traoul/.rbenv/bin:/mnt/bio/ngs/data/home/johndoe/.rbenv/shims:/mnt/\n\tbio/ngs/data/home/johndoe/.rbenv/bin:/usr/local/sbin:/usr/local/bi\n\tn:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games,\n\tPBS_O_MAIL=/var/mail/johndoe,PBS_O_SHELL=/bin/bash,\n\tPBS_SERVER=spark,PBS_O_WORKDIR=/mnt/bio/ngs/data/home/johndoe\n    etime = Mon Sep  2 18:43:10 2013\n    submit_args = -l ncpus=2 -l nice=0\n    start_time = Mon Sep  2 18:43:11 2013\n    start_count = 1\n    fault_tolerant = False\n    submit_host = deep.space.nine"
  # job = job_id == "2770" ? q.mock(t.apply(p.parse(s.gsub(/\n\t/,'')))) : []
  if job.empty?
    return status 404
  else
    json :job => job.first
  end
	# if job.empty?
 #    "There is no job running with id #{job_id}"
	# else

 #  	haml :qstat_job, :format => :html5, :locals => {:job => job.first} #get the first and unique elment if the array is not empty
 #  end
end

get '/qstat/job/fields' do
  json :job_fields => TORQUE::Qstat::Job.fields
end

get '/qstat/:job_id/:field' do |job_id, field|


  # puts TORQUE::Qstat::Job.fields
  if TORQUE::Qstat::Job.fields.include? field
    # q = TORQUE::Qstat.new
    # p = TORQUE::Qstat::Parser.new
    # t = TORQUE::Qstat::Trans.new
    # s= "Job Id: 2770.deep.space.nine\n    Job_Name = STDIN\n    Job_Owner = johndoe@deep.space.nine\n    resources_used.cput = 00:00:00\n    resources_used.mem = 3148kb\n    resources_used.vmem = 32528kb\n    resources_used.walltime = 00:28:05\n    job_state = R\n    queue = bio\n    server = deep.space.nine\n    Checkpoint = u\n    ctime = Mon Sep  2 18:43:10 2013\n    Error_Path = deep.space.nine:/mnt/bio/ngs/data/home/johndoe/STDIN.e2770\n    exec_host = scrapper/0\n    exec_port = 15003\n    Hold_Types = n\n    Join_Path = n\n    Keep_Files = n\n    Mail_Points = a\n    mtime = Mon Sep  2 18:43:11 2013\n    Output_Path = deep.space.nine:/mnt/bio/ngs/data/home/johndoe/STDIN.o2770\n\t\n    Priority = 0\n    qtime = Mon Sep  2 18:43:10 2013\n    Rerunable = True\n    Resource_List.ncpus = 2\n    Resource_List.nice = 0\n    session_id = 16963\n    Variable_List = PBS_O_QUEUE=bio,PBS_O_HOST=deep.space.nine,\n\tPBS_O_HOME=/mnt/bio/ngs/data/home/johndoe,PBS_O_LANG=it_IT.UTF-8,\n\tPBS_O_LOGNAME=johndoe,\n\tPBS_O_PATH=/mnt/bio/ngs/data/opt/fastx_toolkit/bin:/mnt/bio/ngs/data/\n\topt/bedtools/bin:/mnt/bio/ngs/data/opt/fuseki:/mnt/bio/ngs/data/opt/je\n\tna/bin:/mnt/bio/ngs/data/opt/CASAVA/bin:/mnt/bio/ngs/data/bin/cloaked-\n\thipster/utils:/mnt/bio/ngs/data/bin/cloaked-hipster/utils/ngs/pipeline\n\ts:/mnt/bio/ngs/data/bin/cloaked-hipster/utils/db:/mnt/bio/ngs/data/opt\n\t/trimmomatic:/mnt/bio/ngs/data/opt/PHYLOCSF/hmmer-3.0-linux-intel-x86_\n\t64/binaries:/mnt/bio/ngs/data/opt/PHYLOCSF/mlin-PhyloCSF-983a652/:/mnt\n\t/bio/ngs/data/bin/cloaked-hipster/ncrnapp/PBS_pipeline/:/mnt/bio/ngs/d\n\tata/opt/bowtie-0.12.9:/mnt/bio/ngs/data/opt/bowtie_current:/mnt/bio/ng\n\ts/data/opt/STAR_current:/mnt/bio/ngs/data/opt/RSeQC-2.3.5/RQC/usr/loca\n\tl/bin:/mnt/bio/ngs/data/opt/tophat_current:/mnt/bio/ngs/data/opt/PASA/\n\tscripts:/mnt/bio/ngs/data/opt/PASA/bin:/mnt/bio/ngs/data/opt/fasta/bin\n\t:/mnt/bio/ngs/data/opt/cufflinks:/mnt/bio/ngs/data/opt/samtools:/mnt/b\n\tio/ngs/data/opt/samtools/bcftools:/mnt/bio/ngs/data/opt/samtools/misc:\n\t/mnt/bio/ngs/data/opt/STAR_current/bin:/mnt/bio/ngs/data/opt/gmap/bin:\n\t/mnt/bio/ngs/data/opt/velvet:/mnt/bio/ngs/data/opt/velvet/contrib/colu\n\tmbus_scripts:/opt/blat:/mnt/bio/ngs/data/opt/oases/:/mnt/bio/ngs/data/\n\topt/oases/scripts:/mnt/bio/ngs/data/opt/trinityrnaseq:/mnt/bio/ngs/dat\n\ta/opt/trinityrnaseq/util:/usr/local/bin/:/mnt/bio/ngs/data/home/bonnal\n\traoul/.rbenv/bin:/mnt/bio/ngs/data/home/johndoe/.rbenv/shims:/mnt/\n\tbio/ngs/data/home/johndoe/.rbenv/bin:/usr/local/sbin:/usr/local/bi\n\tn:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games,\n\tPBS_O_MAIL=/var/mail/johndoe,PBS_O_SHELL=/bin/bash,\n\tPBS_SERVER=spark,PBS_O_WORKDIR=/mnt/bio/ngs/data/home/johndoe\n    etime = Mon Sep  2 18:43:10 2013\n    submit_args = -l ncpus=2 -l nice=0\n    start_time = Mon Sep  2 18:43:11 2013\n    start_count = 1\n    fault_tolerant = False\n    submit_host = deep.space.nine"
    job = TORQUE::Qstat.new.query job_id: job_id
    # job = q.mock(t.apply(p.parse(query.gsub(/\n\t/,''))))
    json field.to_sym => job.first[field.to_sym]
  else
    return status 404
  end
  # if job.empty?
 #    "There is no job running with id #{job_id}"
  # else

 #    haml :qstat_job, :format => :html5, :locals => {:job => job.first} #get the first and unique elment if the array is not empty
 #  end
end


__END__

@@ layout
%html
  %head
    = bootstrap_assets
  %body
    - container :fluid do
      .navbar
        .navbar-inner
          %a{class:"brand", href:"#"} TORQUE PBS
          %ul{class:"nav"}
            %li{class:"active"}
              %a{href:"#"} Getting Started
            %li 
              %a{href:"#"} Documentation
            %li 
              %a{href:"#"} REST Api
            %li 
              %a{href:"#"} About
            %li 
              %a{href:"#"} Contact
 

      - row do
        - span8 do
          = yield
        - span4 :offset => 4 do
          footer