## How to Run

```
docker-compose up -d
docker-compose exec app bash
export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=yyy
export AWS_REGION=zzz
ruby create_books_trigger.rb
```
