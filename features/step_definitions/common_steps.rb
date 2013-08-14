Given(/^the server "(.*?)"$/) do |server_name|
  TORQUE.server = server_name # express the regexp above with the code you wish you had
end


When(/^I request the server name without specify the hostname$/) do
  @server = TORQUE.server
end

When(/^I request the server name$/) do
  @server = TORQUE.server # express the regexp above with the code you wish you had
end

# Then(/^I should get a "(.*?)"$/) do |reply|
#   @server.should be_an_instance_of(Rye::Box) # express the regexp above with the code you wish you had
# end

Then(/^I should get a "(.*?)" on "(.*?)"$/) do |ssh_manager_object, hostname|
  @server.should be_an_instance_of(Object.const_get(ssh_manager_object)) # express the regexp above with the code you wish you had
  @server.host.should == hostname
end