require 'json'
require 'aws-sdk'

class BooksTrigger
  SUMMERY_KEY = '#SUMMERY#'.freeze

  def run(event, context)
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
    if summery_exist?
      p "update #{total_cost}"
      dynamodb.update_item(
        {
          table_name: 'books',
          key: {
            title: SUMMERY_KEY
          },
          expression_attribute_values: {
            total_cost: total_cost
          },
          update_expression: 'SET cost = cost + :total_cost'
        }
      )
    else
      p "insert #{total_cost}"
      dynamodb.put_item(
        {
          table_name: 'books',
          item: {
            title: { s: SUMMERY_KEY },
            cost: { n: total_cost }
          }
        }
      )
    end
  end

  def summery_exist?
    resp = dynamodb.get_item(
      {
        key: {
          'title' => SUMMERY_KEY
        },
        table_name: 'books'
      }
    )
    resp.item
  end

  def dynamodb
    @dynamodb ||= Aws::DynamoDB::Client.new
  end
end

def handler(event:, context:)
  handler = BooksTrigger.new
  handler.run(event, context)
end
