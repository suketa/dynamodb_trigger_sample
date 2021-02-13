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

  def arn(table_name)
    res = get_role(table_name)
    res.role.arn
  end

  def create(table_name)
    arn = dynamodb_table.stream_arn(table_name)
    policy = create_policy(table_name, arn)
    create_role(table_name, policy)
  end

  def create_role(table_name, policy)
    res = get_role(table_name)
    return res if res

    iam.create_role(
      assume_role_policy_document: lambda_trigger_role(table_name),
      role_name: role_name(table_name)
    )
    iam.attach_role_policy(
      policy_arn: policy.arn,
      role_name: role_name(table_name)
    )
    get_role(table_name)
  end

  private

  def lambda_trigger_role(table_name)
    file = "#{File.dirname(File.absolute_path(__FILE__))}/lambda_#{table_name}_trigger_role.json"
    File.read(file)
  end

  def get_role(table_name)
    iam.get_role(role_name: role_name(table_name))
  rescue Aws::IAM::Errors::NoSuchEntity
    nil
  end

  def policy_name(table_name)
    "dynamodb_#{table_name}_trigger_policy"
  end

  def role_name(table_name)
    "lambda_#{table_name}_trigger_role"
  end

  def iam
    @iam ||= Aws::IAM::Client.new
  end

  def dynamodb_table
    @dynamodb_table ||= DynamodbTable.new
  end
end
