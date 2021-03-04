require 'json'
require 'aws-sdk'

class BooksTrigger
  VERSION = '1.1'.freeze

  SUMMERY_KEY = '#SUMMERY#'.freeze

  def run(event, _context)
    p event['Records']
    return if event['Records'].size == 1 && summary?(event['Records'][0]['dynamodb'])

    total_cost = event['Records'].inject(0) { |total, rec| total + cost(rec['dynamodb']) }
    update_total_cost(total_cost) if total_cost != 0
  end

  def summary?(record)
    record['Keys']['title'] && record['Keys']['title']['S'] == SUMMERY_KEY
  end

  def cost(record)
    return 0 if summary?(record)

    new_cost = record['NewImage'] ? cost_value(record['NewImage']) : 0
    old_cost = record['OldImage'] ? cost_value(record['OldImage']) : 0
    new_cost - old_cost
  end

  def cost_value(image)
    image['cost']['N'].to_i
  end

  def update_total_cost(total_cost)
    dynamodb.update_item(update_item_param(total_cost))
  end

  def update_item_param(total_cost)
    {
      table_name: 'books',
      key: {
        title: SUMMERY_KEY
      },
      expression_attribute_values: {
        ':total_cost' => total_cost,
        ':initial_cost' => 0
      },
      update_expression: 'SET cost = if_not_exists(cost, :initial_cost) + :total_cost'
    }
  end

  def dynamodb
    @dynamodb ||= Aws::DynamoDB::Client.new
  end
end

def handler(event:, context:)
  p self
  p self.class
  puts "BooksTrigger::VERSION = #{BooksTrigger::VERSION}"
  books_trigger = BooksTrigger.new
  books_trigger.run(event, context)
end
