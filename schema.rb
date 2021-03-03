# frozen_string_literal: true

module Schema
  BOOKS = {
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
      stream_enabled: true,
      stream_view_type: 'NEW_AND_OLD_IMAGES'
    },
    billing_mode: 'PAY_PER_REQUEST',
    table_name: 'books'
  }.freeze
end
