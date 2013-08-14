Feature: Configure torque_rm
  In order to interact with the Torque server
  As a user I must configure the system

  Scenario: Torque is the localhost
    When I request the server name without specify the hostname
    Then I should get a "Rye::Box" on "localhost"

  Scenario: Torque is a remote machine
    Given the server "torque.remote.net"
    When I request the server name
    Then I should get a "Rye::Box" on "torque.remote.net"

  Scenario: Torque binary are installed in the default location
    Given the server "torque.remote.net"
    When I try to get a qstat
    Then the server tell me it can execute the command

  Scenario: Torque binary are not installed in the default location
    Given the server "torque.remote.net"
    When I try to get a qstat
    Then the server tell me it can not execute the command