# torque_rm

Example of configuration:

    TORQUE.qcommands_path='/usr/bin'
    TORQUE.server = "my_grid.remote.net"
    job = TORQUE::Qsub.new  m: "abe", name:"FirstTest", shell: '/bin/bash', ppn: 4
    job.script = "echo `hostname`; sleep 1000"
    job.submit
    stats=TORQUE::Qstat.new

    # get all stats on all jobs
    stats.query

    # select stats from only the submitted job
    stat.query job_id: job.id

    # it is also possible to get the stats from a single job
    job.stat

## HowItWorks
Torque_Rm uses Rye as interface with a local/remote computer/server, using ssh, so every command
is a executed with ssh. Rye also guarantees a certain level of security disabling dangerous operations
like moving, deleting files or traversing recursevely a directory. Obviously this feature can be disabled,
but for now it is the default way Torque_Rm operates.

## Job Configurations
### Where files are saved ?
By default torque_rm creates/transfers files in the user home directory `~`. It's possible to change
this default behaviour setting an internal variable when a `job` is created on managed.
Considering the example above configuring the wrinting directory before submitting the `job`:

    job.root_directory = '/my/personal/path'

or

    job.working_directory = '/my/personal/path'

`root` has precedence on `working` directory. It is possible to configure the `root`/`working` directory
at the time of creation of the new job using the usual hash key/value convention.

    :root_directory => '/my/personal/path'
or 
    
    :working_directory => '/my/personal/path'

## Configuration

### Saving

It is possible to save in a configuration file `server` and `path`.
User can sare a configuration file:

    TORQUE.qcommands_path='/usr/bin'
    TORQUE.server = "my_grid.remote.net"
    TORQUE.save_config

it will create a YAML file `~/.torque_rm.yaml` in the user home directory.
In case the user wants to save the configuration in a custom location 

    TORQUE.save_config "file_name"

### Loading

Read a configuration from the dafult location `~/.torque_rm.yaml`

    TORQUE.load_config

In case the user has a custom file
    
    TORQUE.load_config "file_name"


## Define a job using a DSL 

    rhostname = TORQUE::Qsub.new do |job|
            job.m = "abe"
            job.name = "FirstTest"
            job.shell = '/bin/bash'
            job.ppn = 4
            job.script = "echo `hostname`; sleep 1000"
          end
    rhostname.submit
    rhostname.stat

## Stats

When a job is submitted, is possible to get some stats

    [{:job_id=>"2750.sun.universe.space"@1387,
      :job_name=>"FirstTest"@1421,
      :job_owner=>"helios@sun.universe.space"@1447,
      :job_state=>"Q"@1489,
      :queue=>"bio"@1503,
      :server=>"sun.universe.space"@1520,
      :checkpoint=>"u"@1551,
      :ctime=>"Tue Aug 27 15:56:41 2013"@1565,
      :error_path=>
       "sun.universe.space:/home/helios/FirstTest.e2750"@1607,
      :hold_types=>"n"@1689,
      :join_path=>"n"@1707,
      :keep_files=>"n"@1726,
      :mail_points=>"abe"@1746,
      :mtime=>"Tue Aug 27 15:56:41 2013"@1762,
      :output_path=>
       "spark.ingm.ad:/home/helios/FirstTest.o2750"@1805,
      :priority=>"0"@1885,
      :qtime=>"Tue Aug 27 15:56:41 2013"@1899,
      :rerunable=>"True"@1940,
      :resource_list_nodect=>"1"@1972,
      :resource_list_nodes=>"1:ppn=4"@2000,
      :shell_path_list=>"/bin/bash"@2030,
      :variable_list=>
       "PBS_O_QUEUE=bio,PBS_O_HOST=spark.ingm.ad,PBS_O_HOME=/home/helios,PBS_O_LANG=it_IT.UTF-8,PBS_O_LOGNAME=helios,PBS_O_PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/home/helios/.rvm/bin,PBS_O_MAIL=/var/mail/helios,PBS_O_SHELL=/bin/bash,PBS_SERVER=spark,PBS_O_WORKDIR=/home/helios\n"@2060,
      :etime=>"Tue Aug 27 15:56:41 2013"@2456,
      :submit_args=>"FirstTest.qsub"@2499,
      :fault_tolerant=>"False"@2535,
    :submit_host=>"sun.universe.space"@2559}]

directly from the job
    
    job.stat

or by requesting the information using the specific object

    stats=TORQUE::Qstat.new

    # select stats from only the submitted job
    stat.query job_id: job.id

it will return an hash but is also possible to return the raw string from TORQUE/PBS

    stat.query job_id: job.id, type: :raw   

Quering multiple jobs at the same time is possible as well (note the 's' after 'id'):

    stat.query job_ids: ["2751.sun.universe.space","2752.sun.universe.space","2754.sun.universe.space","2755.sun.universe.space"]


## Delete Jobs

From a qsub object if submitted:

    job.rm

Directly from PBS:

    TORQUE::Qdel.rm("2750.sun.universe.space")

## Contributing to torque_rm
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2013 Raoul Jean Pierre Bonnal. See LICENSE.txt for
further details.

