class Lambda
  def create_trigger_function(table_name, s3_bucket, s3_key, role)
    lambda.create_function(
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
  end

  private

  def lambda
    @lambda ||= Aws::Lambda::Client.new
  end
end
