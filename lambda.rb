class Lambda
  def create_trigger_function(table_name, s3_bucket, s3_key, role)
    res = get_function(table_name)
    return res if res

    res = lambda.create_function(
      function_name: "#{table_name}_trigger",
      runtime: 'ruby2.7',
      handler: "#{table_name}_trigger.handler",
      code: {
        s3_bucket: s3_bucket,
        s3_key: s3_key
      },
      role: role,
      publish: true
    )
    create_event_source_mapping("#{table_name}_trigger", table_name)
    res.function_arn
  end

  private

  def get_function(table_name)
    lambda.get_function(function_name: "#{table_name}_trigger")
  rescue
    nil
  end

  def create_event_source_mapping(function_name, table_name)
    lambda.create_event_source_mapping(
      event_source_arn: event_source_arn(table_name),
      function_name: function_name,
      starting_position: 'LATEST',
      enabled: true
    )
  rescue Aws::Lambda::Errors::InvalidParameterValueException => e
    raise e unless /^Stream not found: / =~ e.message
  end

  def lambda
    @lambda ||= Aws::Lambda::Client.new
  end

  def event_source_arn(table_name)
    dynamodb_table.stream_arn(table_name)
  end

  def dynamodb_table
    @dynamodb_table ||= DynamodbTable.new
  end
end
