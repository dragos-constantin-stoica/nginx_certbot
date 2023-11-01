#!/bin/bash

#----------------------------------------------------------------------------
# This is setup, deploy and run script for
# Compnents:
# - Nginx
# - CertBot
#
# @company: Free Time Software
# @date: 01.11.2023
# @version: 0.0.1
# @author: dragos.constantin.stoica@outlook.com
#----------------------------------------------------------------------------

# Local variables shared with docker compose and each container
source .env

# Auxiliary functions used to display message on the screen
source emoji_color.sh

# display usage and help
usage(){
    local __usage="Usage:
    -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
    $0 ssl
        setup SSL certificates from Lets Encrypt via Cerbot
    $0 run
        main execution loops, launch Data Solution Blueprint
    $0 stop
        stop execution loop
    $0 cleanup
        clean all folders and data
    $0 prune
        prune system for docker
    $0 test
        test the color and emoji utility functions
    -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
"
    echo -e "$__usage"
	return
}

# certbot ssl management
certbotssl(){
    echocolor "Setup SSL certificates from Lets Encrypt using Certbot" "BYellow" "Locked"

    cp nginx/conf/nginx_setup nginx/conf/nginx.conf
		docker compose up -d
		sleep 20
    
    local FOLDERS=( "./certbot" "./certbot/www" "./certbot/conf")
    for i in "${FOLDERS[@]}"
    do
	    if [ ! -d "$i" ]; then
        mkdir -m 0777 -p $i
    fi
    done
    
    docker compose run --rm  certbot certonly --webroot --webroot-path /var/www/certbot/ --force-renewal --email ${CERT_EMAIL} -d ${CERT_DOMAIN} --agree-tos --non-interactive

    docker compose down
		cp nginx/conf/nginx_ssl nginx/conf/nginx.conf
    
    echocolor "DONE >>> SSL certificates" "BYellow" "Locked"
}

# clean up all folders
cleanup(){
    echocolor "Cleanup stage" "BIRed" "NoEntry"
    echo "Do you want to delete ALL data?"
    select yn in "Yes" "No"
    do
        case $yn in
            Yes )
                #delete CouchDB and Lets Encrypt folders
                local FOLDERS=("./certbot")
                for i in "${FOLDERS[@]}"
                do
                    if [ -d "$i" ]; then
                        sudo rm -fr $i
                    fi
                done; break ;;
            No )
                echo "Wise decission! This actions would have been irreversible :)"; break;;
            * )
                echo "Select one option from the list." ;;
        esac
    done

    echocolor "DONE >>> Cleanup stage" "BIRed" "Robot"
}

# run function
run(){
    echocolor "Run stage" "BIGreen" "Whale"
    docker compose up -d

    echo -e "\n\n"
    echocolor "DONE >>> Run stage" "BIGreen" "Whale"
}

# stop function
stop(){
    echocolor "Stop stage" "On_Red" "Bomb"
    docker compose down
    echocolor "DONE >>> Stop stage" "On_Red" "Bomb"
}

# prune function
prune(){
   echocolor "Prune docker system" "BPurple" "Broom"
   docker system prune -f
   echocolor "DONE >>> Prune stage" "BPurple" "Toilet"
}

##############################################################################
# main script

# process command line parameters
if [ $# -lt 1 ]; then
	usage
	exit 0
fi
#echo $1, $2, $3, $4

case $1 in
    "ssl")      certbotssl ;;
    "cleanup")  cleanup ;;
    "run")      run ;;
    "stop")     stop ;;
    "prune")    prune;;
    "test")     test_color; test_emoji;;
    "usage")    usage ;;
    *)      	echocolor "unknown command: $1" "On_IRed" "Poo"
	            usage ;;
esac

exit 0

# end of main script
##############################################################################
