class Lambda
  def create_trigger_function(table_name, s3_bucket, s3_key, role)
    p s3_bucket
    lambda.create_function(
      function_name: "#{table_name}_trigger",
      runtime: 'ruby2.7',
      handler: "#{table_name}_trigger",
      code: {
        s3_bucket: s3_bucket,
        s3_key: s3_key
      },
      role: role
    )
  end

  private

  def lambda
    @lambda ||= Aws::Lambda::Client.new
  end
end
