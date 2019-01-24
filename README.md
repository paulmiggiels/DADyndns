# DADyndns

Bash script/client for dynamic DNS via the DirectAdmin API.
Updates the DNS records for one or several subdomains for the script that this server runs on.

## Getting Started

Download a copy
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Should run on any Ubuntu or Debian machine. Designed on Raspbian.

### Installing

Place the script in a folder of your liking. Edit the server variables to the correct user, server and subdomains. Test the script, and then set the cron job.

*Note 1: user & password are stored plaintext - use a login key with CMD_DNS_API_CONTROL permission only for security.
Note 2: for optimal use, set the cron job to log to* `/var/log/DADyndns.log`


## Running the tests

Run the script without the 'ipaddress' file. Upon first run it should create the file and update the DNS records. Verify that the file 'ipaddress' exists and the public IP address is stored there. Run the script again and there should be no output; IP does not need to be changed.


## Author

* **Paul Miggiels** - *Initial work* - [paulmiggiels](https://github.com/paulmiggiels)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
