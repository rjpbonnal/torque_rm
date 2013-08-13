Feature: Submit jobs
  In order to submit a job
  A user should be able to create a batch job
  prividing multiple PBS options
  attaching a shell script

  Scenario: Configure a batch job
    Given the name "MyBatch"
    And I want to use the "/bin/bash" shell    
    And I want to be notified if the job begins
    And I want to be notified if the job ends
    And I want to be notified if the job aborts
    Then I should get a configuration like
      """
      #PBS -m bea
      #PBS -N MyBatch
      #PBS -S /bin/bash

      """

Scenario: Prepare a script to get the hostname from a node
    Given the name "MyBatch"
    And I want to use the "/bin/bash" shell    
    And I want to be notified if the job begins
    And I want to be notified if the job ends
    And I want to be notified if the job aborts
    And I want to set the "working_directory" to "/home/submitter/test_cluster"
    And I want to set the "stdout" to "/home/submitter/test_cluster"
    And I want to set the "stderr" to "/home/submitter/test_cluster"
    And I want to use 4 cpus for a single node
    And the command "echo `hostname`"
    Then I should get the pbs script
      """
      #PBS -d /home/submitter/test_cluster
      #PBS -e /home/submitter/test_cluster
      #PBS -l nodes=1:ppn=4
      #PBS -m bea
      #PBS -N MyBatch
      #PBS -o /home/submitter/test_cluster
      #PBS -S /bin/bash
      echo `hostname`
      """


  Scenario: Get the hostname from a node
    Given the name "MyBatch"
    And I want to use the "/bin/bash" shell    
    And I want to be notified if the job begins
    And I want to be notified if the job ends
    And I want to be notified if the job aborts
    And the command "echo `hostname`"
    Then I should get the name of the execution node
