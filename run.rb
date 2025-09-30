require "dotenv/load"
require_relative "mattermost_api_client"
require_relative "zammad_api_client"

%w[ZAMMAD_API_URL ZAMMAD_API_TOKEN MATTERMOST_WEBHOOK_URL MATTERMOST_CHANNEL].each do |var|
  raise "Environment variable #{var} is not set" if ENV[var].nil? || ENV[var].empty?
end

puts "Fetching data from Zammad…"
open_tickets_counts_by_agent_email = ZammadApiClient.open_tickets_counts_by_agent_email
open_tickets_count = open_tickets_counts_by_agent_email.values.sum
count_new_tickets = ZammadApiClient.count_new_tickets
puts "Done fetching data from Zammad. Got #{count_new_tickets} new tickets and #{open_tickets_count} open tickets."
puts

puts "Building message…"
message = "Rappel Zammad quotidien"
message += "\n\n#{count_new_tickets} nouveaux tickets non-assignés"
message += "\n\net #{open_tickets_count} tickets assignés et ouverts (en attente de réponse) :"
message += "\n"
open_tickets_counts_by_agent_email.sort.each do |agent_email, agent_open_tickets_count|
  agent_email = "N/A" if agent_email == "-"
  message += "\n- #{agent_email}: #{agent_open_tickets_count} ticket(s) ouvert(s)"
end
puts "Done building message."
puts

puts "Sending message to Mattermost channel #{ENV['MATTERMOST_CHANNEL']}…"
MattermostApiClient.send_message(
  channel: ENV["MATTERMOST_CHANNEL"],
  text: message
)
puts "Done sending message to Mattermost."
