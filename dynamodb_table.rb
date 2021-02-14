require 'aws-sdk'

class DynamodbTable
  def create(params)
    describe(params[:table_name]) || dynamodb.create_table(params)
  end

  def stream_arn(table_name)
    resp = describe(table_name)
    return "#{resp.table.table_arn}/stream/*" if resp

    raise "#{table_name} is not found"
  end

  def arn(table_name)
    resp = describe(table_name)
    return resp.table.table_arn if resp

    raise "#{table_name} is not found"
  end

  private

  def describe(table_name)
    retry_count = 0
    begin
      dynamodb.describe_table(table_name: table_name)
    rescue Aws::DynamoDB::Errors::ResourceNotFoundException
      sleep 0.1
      retry if (retry_count += 1) < 10
      nil
    end
  end

  def dynamodb
    @dynamodb ||= initialize_dynamodb
  end

  def initialize_dynamodb
    Aws::DynamoDB::Client.new
  end
end
