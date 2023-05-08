# My home dashboard

Utilizes Docker and [Dashing](http://shopify.github.com/dashing).

# Setup

## Dashing container

```
docker build --tag="local/smashing" .
docker run -d --network=host -m 384m \
    -e HAKEY=(an_api_key_here) \
    --restart=unless-stopped \
    --name=smashing local/smashing
```

## Nginx container

*This could be improved...*

```
docker run -d -p 1280:1280 -m 192m \
    -v=`pwd`/nginx:/etc/nginx/conf.d:ro \
    --restart=unless-stopped \
    --name=nginx nginx
```
