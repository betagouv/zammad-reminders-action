class ZammadApiClient
  def self.connection
    @connection ||= Faraday.new(
      url: ENV["INPUT_ZAMMAD_API_URL"].freeze,
      headers: { Authorization: "Token token=#{ENV['INPUT_ZAMMAD_API_TOKEN']}" }
    ) do |builder|
      builder.request :json
      builder.response :json
      builder.response :raise_error # raise an error on 4xx and 5xx responses
    end
  end

  def self.search_tickets(condition:, query: nil)
    connection.post("api/v1/tickets/search?#{query}", { condition: }).body
  end

  def self.count_tickets(condition:)
    params = { condition: }
    response_data = connection.post("api/v1/tickets/search?only_total_count=1", params).body
    response_data.fetch("total_count")
  end

  def self.count_new_tickets
    count_tickets(
      condition: {
        "ticket.state_id": { operator: "is", value: ["1"] }, # "1" = new
        "ticket.owner_id": { operator: "is", value: ["1"] }, # "1" = unassigned, might be useless here
      }
    )
  end

  def self.count_open_tickets(owner_id:)
    count_tickets(
      condition: {
        "ticket.state_id": { operator: "is", value: %w[2] }, # "2" = open
        "ticket.owner_id": { operator: "is", value: [owner_id] },
      }
    )
  end

  def self.search_open_tickets
    search_tickets(
      condition: {
        "ticket.state_id": { operator: "is", value: %w[2] }, # "2" = open. open != new
      },
      query: "per_page=200&expand=true" # 200 seems to be the max
    )
  end

  def self.open_tickets_counts_by_agent_email
    search_open_tickets.map{ _1["owner"] }.tally
  end
end
