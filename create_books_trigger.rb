require_relative 'dynamodb_table'
require_relative 'dynamodb_trigger_role'
require_relative 's3'
require_relative 'lambda'
require_relative 'schema'

# books = {
#   attribute_definitions: [
#     {
#       attribute_name: 'title',
#       attribute_type: 'S'
#     }
#   ],
#   key_schema: [
#     {
#       attribute_name: 'title',
#       key_type: 'HASH'
#     }
#   ],
#   stream_specification: {
#     stream_enabled: true, # required
#     stream_view_type: 'NEW_AND_OLD_IMAGES'
#   },
#   billing_mode: 'PAY_PER_REQUEST',
#   table_name: 'books'
# }

dynamodb_table = DynamodbTable.new
dynamodb_table.create(Schema::BOOKS)
table_name = Schema::BOOKS[:table_name]
role = DynamodbTriggerRole.new
role.create(table_name)
s3 = S3.new(table_name)
s3.upload_trigger
lambda_cli = Lambda.new
lambda_cli.create_trigger_function(table_name, s3.bucket_name, s3.key, role.arn(table_name))
