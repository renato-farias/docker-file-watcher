# docker-file-watcher

Manage docker compose dev environments restarting services whenever code files are updated.

This project used as reference the [docker-inotify](https://github.com/pstauffer/docker-inotify).

## Usage

Simply add a new service to your docker-compose project following the example below:

```yaml
services:
  webapp:
    image: mywebapp-image:latest
    ports:
    - target: 8080
      published: 8080
      protocol: tcp
    depends_on:
      docker-file-watcher:
        condition: service_started
    volumes:
      - "./src:/app"
  docker-file-watcher:
    image: "rcdfs/docker-file-watcher:latest"
    container_name: "docker-file-watcher"
    configs:
    - source: docker-file-watcher.config
      target: /tmp/docker-file-watcher.config

    volumes:
    - "./docker-compose.yaml:/tmp/docker-compose.yaml:ro"
    - "/var/run/docker.sock:/var/run/docker.sock"
    - "./src/:/watch:ro"

    restart: always

configs:
  docker-file-watcher.config:
    content: |
      webapp .*\.py
      another-service .*\.(css|js)
```
