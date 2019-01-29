#!/bin/bash

# User and server details
user="username"
password="loginkey"
server="https://server.yourhosting.com:2222"
domain="mydomain.com"
declare -a subdomains=("subdomain1 subdomain2")

# Local file
IP_file="ipaddress"

# Main function
#
main() {
  
  if detect_IP_change ; then
    echo "IP needs updating from ${stored_IP} to ${curr_IP}."
    
    for subdomain in ${subdomains}; do
      echo "Updating domain ${subdomain}."
      if ! update_DNS ${subdomain}; then
        # User choice: return 1 prevents other subdomains from being updated.
        # IP_file will also not be updated, so the next time the script is ran
        # it will attempt to update.
        echo "Domain ${subdomain} was not updated."
        return 1
      fi
    done
    
    # Only update IP record if all DNS updates are successful
    sed -i "1s/.*/${curr_IP}/g" ${IP_file}
    echo "All domains updated to ${curr_IP}."
  fi
}


# Test an IP address for validity:
# Usage:
#      if valid_ip IP_ADDRESS; then echo good; else echo bad; fi
# Courtesy of Mich Frazier: https://www.linuxjournal.com/content/validating-ip-address-bash-script
#
valid_IP() {
  local ip=$1
  local stat=1
  
  # Test format first: 4 numeric parts (1-3 characters per part) separated by dots (.)
  if [[ ${ip} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    # Modify Internal Field Separator to a dot (.) to parse the IP as words
    OIFS=$IFS
    IFS='.'
    ip=($ip)
    IFS=$OIFS
    # Verify that each of the "words" in IP are within range 0-255
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
      && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    stat=$?
    fi
    return $stat
}

# Check if IP update is required. Retrieves public IP and compares to local stored IP
# Returns 0 (no error) when IP has changed
# Exits when public IP cannot be retrieved
#
detect_IP_change() {
  
  # Default is changed: return 0
  local changed=0
  
  # Retrieve public IP address and validate
  curr_IP=$(dig @resolver1.opendns.com ANY myip.opendns.com +short)
  if ! valid_IP ${curr_IP}; then
    echo "Public IP was not retrieved: $CURR_ADD. Exiting script.."
    return 1
  fi
  
  # If file non-existent or not-writeable, or empty: update IP
  # Otherwise, read IP from file and compare to retrieved IP
  if [ ! -w $IP_file ]; then
    echo "Local file \"${IP_file}\" not found. Creating new file.."
    stored_IP="no address"
    touch $IP_file
    echo ${stored_IP}>${IP_file}
  elif [ ! -s $IP_file ]; then
    echo "Local file is empty."
    stored_IP="no address"
    echo ${stored_IP}>${IP_file}
  else
    # Read old address from file
    read -r stored_IP<$IP_file
    
    if [ "${stored_IP}" == "${curr_IP}" ]; then
      # No change, return 1
      changed=1
    fi
  fi
  
  return $changed
}

# Command-function for DirectAdmin API commands
# Usage:
#    API_CMD "API command" "Text reference (logging)"
#
API_command() {
  
  local ret=1
  local action=${1}
  local respons=$(curl -s --max-time 15 --user $user:$password "${server}/CMD_API_DNS_CONTROL?domain=${domain}${action}")
  # Expected return string: error=0&text=Records%20Deleted&details=View records
    
  if [[ ${respons} =~ ^error=([0-1])\&text=(.*)$ ]]; then
    
    if [ ${BASH_REMATCH[1]} -eq 0 ]; then
      ret=0
    else
      error=$(sed -r 's/(%20)+/\ /g' <<< ${BASH_REMATCH[2]})
      error=$(sed -r 's/(\&details=)+/: /g' <<< ${error})
      echo "Error in \"${2}\". Error: \"${error}\""
    fi
  fi
  
  return $ret
}

update_DNS() {
  local ret=1
  
  API_command "&action=select&arecs0=name%3D${1}" "Delete record"
  # Only update record if the previous is deleted to avoid double records
  if [ $? ]; then
    API_command "&action=add&type=A&name=${1}&value=${curr_IP}" "Add record"
    ret=$?
  fi 
  
  return $ret
}

### RUN MAIN CODE ###

main
exit 1
