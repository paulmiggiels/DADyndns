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

*Note: user & password are stored plaintext - use a login key with CMD_DNS_API_CONTROL permission only for security.*

Cron-job example to run every 30 minutes. Runs the job from within the folder, so the ipaddress file and log are stored in the same location as the shell script.
```
*/30 * * * * cd /home/usr/scripts/DADyndns && ./DADyndns.sh >> DADyndns.log 2>&1
```

Optional: pipe the output through a timestamp script to add date/time stamp to the logs. See http://mpcabd.xyz/adding-a-timestamp-to-command-output-in-linux/ for the timestamp script.
```
*/30 * * * * cd /home/usr/scripts/DADyndns && ./DADyndns.sh 2>&1 | /home/usr/scripts/timestamp.sh >> DADyndns.log
```

## Running the tests

Run the script without the 'ipaddress' file. Upon first run it should create the file and update the DNS records. Verify that the file 'ipaddress' exists and the public IP address is stored there. Run the script again and there should be no output; IP does not need to be changed.


## Author

* **Paul Miggiels** - *Initial work* - [paulmiggiels](https://github.com/paulmiggiels)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
