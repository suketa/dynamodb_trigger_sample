class Lambda
  def create_trigger_function(table_name, s3_bucket, s3_key, role)
    res = get_function(table_name)
    if res
      update_code("#{table_name}_trigger", s3_bucket, s3_key, role)
    else
      create_function("#{table_name}_trigger", s3_bucket, s3_key)
    end
  end

  private

  def create_function(function_name, s3_bucket, s3_key, role)
    res = lambda.create_function(
      function_name: function_name,
      runtime: 'ruby2.7',
      handler: "#{function_name}.handler",
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

  def update_code(function_name, s3_bucket, s3_key)
    lambda.update_function_code(
      function_name: function_name,
      s3_bucket: s3_bucket,
      s3_key: s3_key
    )
  end

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
