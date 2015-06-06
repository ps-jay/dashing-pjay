# My home dashboard

Utilizes Docker and [Dashing](http://shopify.github.com/dashing).

# Setup

## Dashing container

```
docker build --tag="local/dashing" docker
docker run -d -p 3030:3030 -m 256m -v=/opt/dashing/dashboards:/dashboards:ro -v=/opt/dashing/jobs:/jobs:ro -v=/opt/dashing/config:/config:ro -v=/opt/dashing/public:/public:ro -v=/opt/dashing/widgets:/widgets:ro -v=/opt/energy:/energy-data:ro --name=dashing local/dashing
```

## Nginx container

```
docker run -d -p 1280:80 -m 192m --link dashing:dashing -v=/opt/dashing/nginx:/etc/nginx/conf.d:ro --name=nginx nginx
```
