class DynamodbTriggerRole
  def create_policy(table_name, arn)
    policy = find_policy(table_name)
    return policy if policy

    resp = iam.create_policy(
      policy_name: "#{table_name}_trigger_policy",
      policy_document: policy_document(table_name, arn)
    )
    resp.policy
  end

  def find_policy(table_name)
    is_truncated = true
    policy = nil
    while is_truncated
      resp = iam.list_policies(scope: 'Local')
      is_truncated = resp.is_truncated
      policy = resp.policies.find { |pol| pol.policy_name == "#{table_name}_trigger_policy" }
      break if policy
    end
    policy
  end

  def policy_document(table_name, arn)
    file = "#{File.dirname(File.absolute_path(__FILE__))}/#{table_name}_trigger_policy.json"
    str = File.read(file)
    str.gsub('{{dynamodb_stream_arn}}', arn)
  end

  def stream_arn(table_name)
    retry_count = 0
    begin
      resp = dynamodb.describe_table(table_name: table_name)
      "#{resp.table.table_arn}/stream/*"
    rescue Aws::DynamoDB::Errors::ResourceNotFoundException => e
      sleep 1
      retry if (retry_count += 1) < 10
      raise e
    end
  end

  def create(table_name)
    arn = stream_arn(table_name)
    policy_arn = create_policy(table_name, arn)
  end

  private

  def dynamodb
    @dynamodb ||= Aws::DynamoDB::Client.new
  end

  def iam
    @iam ||= Aws::IAM::Client.new
  end
end
