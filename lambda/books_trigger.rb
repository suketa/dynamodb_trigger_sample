require 'json'

def summary?(record)
  record['Keys']['title'] == '#SUMMERY#'
end

def add_summary(record)
  return unless record['NewImage']['cost']

  puts record['NewImage']['cost']
end

def handler(event:, _context:)
  event['Records'].each do |record|
    dynamodb_record = record['dynamodb']
    next if summary?(dynamodb_record)

    add_summary(dynamodb_record)
  end
end
