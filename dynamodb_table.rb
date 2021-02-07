require 'aws-sdk'

class DynamodbTable
  def create(params)
    exist?(params[:table_name]) ? nil : dynamodb.create_table(params)
  end

  private

  def exist?(table_name)
    response = dynamodb.list_tables
    next_page = true
    while next_page
      return true if response.table_names.find { |table| table == table_name }

      next_page = response.next_page?
      response = response.next_page if next_page
    end
    false
  end

  def dynamodb
    @dynamodb ||= initialize_dynamodb
  end

  def initialize_dynamodb
    Aws::DynamoDB::Client.new
  end
end
