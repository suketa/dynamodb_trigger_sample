require_relative 'dynamodb_table'

class DynamodbTriggerRole
  def create_policy(table_name, arn)
    policy = find_policy(table_name)
    return policy if policy

    resp = iam.create_policy(
      policy_name: policy_name(table_name),
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
      policy = resp.policies.find { |pol| pol.policy_name == policy_name(table_name) }
      break if policy
    end
    policy
  end

  def policy_document(table_name, arn)
    file = "#{File.dirname(File.absolute_path(__FILE__))}/#{policy_name(table_name)}.json"
    str = File.read(file)
    str.gsub('{{dynamodb_stream_arn}}', arn)
  end

  def create(table_name)
    arn = dynamodb_table.stream_arn(table_name)
    policy = create_policy(table_name, arn)
  end

  private

  def policy_name(table_name)
    "dyanmodb_#{table_name}_trigger_policy"
  end

  def iam
    @iam ||= Aws::IAM::Client.new
  end

  def dynamodb_table
    @dynamodb_table ||= DynamodbTable.new
  end
end
