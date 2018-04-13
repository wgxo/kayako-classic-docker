# kayako-classic-docker
Docker scripts for Kayako classic (Swift)

# Notes
The subdir branch was started to run KC and other tools from a path diferent from root: ie. http://host/swift, http://host/drupal, http://host/wordpress, etc.

This configuration assumes that: Drupal, Joomla, etc. exist on ../vendor directory.

The container depends on a external mysql instance named `aladdin_db_1`. Running on the `aladdin_default` network from TNK.

If another MySQL instance is to be used, it needs to be declared in `docker-compose.yml` and in `build.sh`

The swift/kayako-SWIFT directory is a clone of the [Kayako Classic repo](https://github.com/trilogy-group/kayako-SWIFT)

Running `./build.sh` generates a `.env` file with several environment variables and builds the KC container.

The `XDEBUG_HOST` variable is the IP of the host. It permits to debug KC from inside the container using PHPStorm.

When debugging in PHPStorm, set the Server Name to **default**.

