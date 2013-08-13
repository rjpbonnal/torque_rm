Before do
  @qsub = TORQUE::Qsub.new
end

Given /^I want to be notified if the job begins$/ do
  @qsub.m << "b"
end

Given /^I want to be notified if the job ends$/ do
  @qsub.m << "e"
end

Given /^I want to be notified if the job aborts$/ do
  @qsub.m << "a"
end

Given(/^the name "(.*?)"$/) do |job_name|
  @qsub.name = job_name
end


Given(/^I want to use the "(.*?)" shell$/) do |job_shell|
  @qsub.shell = job_shell
end

Given(/^the command "(.*?)"$/) do |job_command|
  @qsub.script = job_command # express the regexp above with the code you wish you had
end

Then(/^I should get a configuration like$/) do |pbs_script|
  @qsub.to_s.should == pbs_script # express the regexp above with the code you wish you had
end

 Then(/^I should get the pbs script$/) do |pbs_script|
  @qsub.to_s.should == pbs_script # express the regexp above with the code you wish you had
end


