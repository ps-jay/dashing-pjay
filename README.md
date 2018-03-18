# My home dashboard

Utilizes Docker and [Dashing](http://shopify.github.com/dashing).

# Setup

## Dashing container

```
docker build --tag="local/dashing" .
docker run -d --network=host -m 384m \
    -e FORECASTIO=(an_api_key_here) \
    -e RE_USERNAME=(user) \
    -e RE_PASSWORD=(pass) \
    --restart=always \
    --name=dashing local/dashing
```

## Nginx container

*This could be improved...*

```
docker run -d -p 1280:1280 -m 192m \
    -v=`pwd`/nginx:/etc/nginx/conf.d:ro \
    --restart=always \
    --name=nginx nginx
```
