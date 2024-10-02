#!/bin/sh

clear

echo "+--------------------------------------------+"
echo "|    Docker tools - api-test bash quick access    |"
echo "+--------------------------------------------+"
echo ""
# Requirements checking 
echo "1 - Checking requirements"
echo ""

# Checking Docker-compose
docCompose="$(which docker compose)"

if [ ! -z "$docCompose" ]; then
    echo "Docker compose installed..."
	echo ""
else
    echo "I require docker compose but it's not installed."; 
    echo "Please vist https://docs.docker.com/compose/install/linux/ to install it."
	echo ""
    exit 1;
fi

# Accessing bash for the apache-php container
docker compose exec api_test bash 