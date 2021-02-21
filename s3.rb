require 'securerandom'

class S3
  attr_reader :table_name

  def initialize(table_name)
    @table_name = table_name
  end

  def upload_trigger
    create_bucket
    put_public_access_block
    s3.put_object(
      body: File.read("./lambda/#{table_name}_trigger.zip"),
      bucket: bucket(table_name),
      key: key
    )
  end

  def bucket_name
    @bucket
  end

  def key
    "#{table_name}_trigger.zip"
  end

  private

  def create_bucket
    bucket = bucket_exist?(bucket(table_name))
    return bucket if bucket

    s3.create_bucket(
      bucket: bucket(table_name),
      acl: 'private'
    )
  end

  def bucket_exist?(bucket)
    bucket_trigger = /^#{bucket.gsub(/-trigger-.*$/, '-trigger')}/
    s3.list_buckets.buckets.find { |b| bucket_trigger =~ b.name }&.name
  end

  def put_public_access_block
    s3.put_public_access_block(
      bucket: bucket(table_name),
      public_access_block_configuration: {
        block_public_acls: true,
        ignore_public_acls: true,
        block_public_policy: true,
        restrict_public_buckets: true
      }
    )
  end

  def bucket(table_name)
    return @bucket if @bucket

    @bucket = "#{table_name}-trigger-#{SecureRandom.uuid}"
    @bucket = bucket_exist?(@bucket) || @bucket
  end

  def s3
    @s3 ||= Aws::S3::Client.new
  end
end
