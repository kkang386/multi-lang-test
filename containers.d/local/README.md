# Containers.d

## Getting Started

To get started running the web server locally, install the latest version of [docker](https://docs.docker.com/docker-for-mac/install/).

## Starting the dev server

You can start the dev server by simply running:

`CONFIG_ENV=local docker-compose up`

### Services

After running the command above, the following services will be started:

| Service Name    | Description                                                 | Port |
| --------------- | ----------------------------------------------------------- | ---- |
| redis-cache     | Caches user information and page renders.                   | 6379 |
| sql-service     | Currently only used to provide a task database for gearman. | 3306 |
| php-my-admin    | A very simple mysql database tool.                          | 8000 |
| gearman-server  | A task coordinator daemon.                                  | 4730 |
| gearman-workers | Task processors for gearman.                                | N/A  |
| app-server      | The main workboard PHP/Apache server.                       | 80   |

### Connect Repo

The node server must be run from the [connect repo](https://github.com/Workboard/connect) it will run on port 1337
### Environments

Instead of editing configuration files, multiple environments can be managed in the `containers.d` directory. Simply copy the `containers.d/local` directory to a new directory in `containers.d` (such as `containers.d/example`), make your changes in the new directory and restart the dev server with the appropriate `CONFIG_ENV` value (`CONFIG_ENV=example docker-compose up`). If you prefer not to share you environment with the work, add your directory to the `containers.d/.gitignore` file to prevent it from being committed.

#### How It Works

To see how environment management works, lets look at how volumes are mounted to the application server.

```
  - ./:/var/www/html/ # Mount root directory to apache server
  ...
  - ./containers.d/${CONFIG_ENV:-dev}/api/:/var/www/html/conf/api/ # Apply per env config
```

Notice that first the entire project directory, `./`, is bound to `/var/www/html` inside the container. After this the `./containers.d/${CONFIG_ENV:-dev}/api/` is bound over the `/var/www/html/conf/api/` directory. By binding over the real application config, it is possible to switch environments with a simple environment variable, rather than edit the main application configuration file.

## Getting to the Workboard site

When accessing the Workboard site, there are host information checks. This prevents you from accessing it locally on using `127.0.0.1` or `localhost` without editing the code that performs these checks. Instead you can bind an accepted Workboard domain to `localhost`. To do this edit the `/etc/hosts` file on your Linux or Macintosh machine, and add the following line

`127.0.0.1 local.myworkboard.com`

This will instruct your network device to route all traffic targeted at `local.myworkboard.com` to your local machine.

## Accessing containers

To list your active containers run

`docker ps`

To see the CPU/Memory stats of your active containers run

`docker stats`

Both will provide the container name and container id. Once you have the id for the container you would like to access, attach a bash shell to it by running

`docker exec -it ${CONTAINER_ID} /bin/bash`

## Inspecting logs

If you don't detach the containers, the content of their logs is output to the console. Yet if you need to inspect specific logs you can do it by accessing the container via SSH.

**Example of how to inspect the main application log:**

    $ docker exec -it app-server /bin/bash
    root@b8301ac12102:/var/www/html# tail -f wb/protected/runtime/application.log

**How to inspect the mail workers log:**

    $ docker exec -it gearman-workers /bin/bash
    root@504adb6eefd2:/# tail -f /var/log/workers/mailer_worker.log

## Teardown the dev server

The dev server can be torn down by running:

`docker-compose down`

### Removing persisted data

Volumes can be dropped when shutting down the docker containers by providing the `-v` argument

`docker-compose down -v`

## Cool Tools

If you use Microsoft's Visual Studio Code, Microsoft provides an extension to easily manage Docker.

https://code.visualstudio.com/docs/azure/docker
