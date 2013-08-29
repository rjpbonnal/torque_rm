require 'parslet'
require 'yaml'
require 'torque_rm/common'
require 'torque_rm/qsub'
require 'torque_rm/qstat'
require 'torque_rm/qdel'

# Try to laod the default configuration
TORQUE.load_config
