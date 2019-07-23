# kayako-classic-docker
Docker scripts for Kayako classic (Swift)

# Notes
The swift/kayako-SWIFT directory is a clone of the [Kayako Classic repo](https://github.com/trilogy-group/kayako-SWIFT)

Running `./build.sh` generates a `.env` file with several environment variables and builds the KC container.

The `XDEBUG_HOST` variable is the IP of the host. It permits to debug KC from inside the container using PHPStorm.

When debugging in PHPStorm, set the Server Name to **default**.

