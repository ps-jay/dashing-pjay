# My home dashboard

Utilizes Docker and [Dashing](http://shopify.github.com/dashing).

# Setup

## Dashing container

```
docker build --tag="local/dashing" docker
docker run -d --network=host -m 384m \
    -v=/opt/energy:/energy-data:ro \
    -e FORECASTIO=(an_api_key_here) \
    --restart=always \
    --name=dashing local/dashing
```

## Nginx container

*This could be improved...*

```
docker run -d -p 1280:80 -m 192m \
    -v=/opt/dashing/nginx:/etc/nginx/conf.d:ro \
    --link dashing:dashing \
    --restart=always \
    --name=nginx nginx
```
