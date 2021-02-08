require_relative 'dynamodb_table'
require_relative 'dynamodb_trigger_role'

books = {
  attribute_definitions: [
    {
      attribute_name: 'title',
      attribute_type: 'S'
    }
  ],
  key_schema: [
    {
      attribute_name: 'title',
      key_type: 'HASH'
    }
  ],
  stream_specification: {
    stream_enabled: true, # required
    stream_view_type: 'NEW_AND_OLD_IMAGES'
  },
  billing_mode: 'PAY_PER_REQUEST',
  table_name: 'books'
}

dynamodb_table = DynamodbTable.new
p dynamodb_table.create(books)
role = DynamodbTriggerRole.new
p role.create('books')
