#!/bin/bash
# Description: Shell-script to start rails server

# To romove created containers execute "docker-compose down"

read -r -p "Install new packages or gems? (Needed only for initial setup) [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
	docker-compose build
fi

#read -r -p "Open bash in the Ruby container? (Used for testing) [y/N] " response
#if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
#then
#  docker-compose start
#  docker exec -it lacrsearch_web_1 bash
#  docker-compose stop
#  exit
#fi

read -r -p "Reset database? (Needed only for initial setup) [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
  docker-compose run web bash -c "rails db:drop && rails db:create && rails db:migrate && rails db:seed"
fi
echo ''
echo 'Starting containers ....'
docker-compose up
