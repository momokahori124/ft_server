# ft_server

# Description

ft_server is a project that asks you to run a server on Debian Buster through Docker with a Wordpress, Phpmyadmin and Mysql runnning.

# Usage

```shell
# Build image
$ docker build -t test .
# Run image
$ docker run -d -p 8080:80 -p 443:443 test 
```
