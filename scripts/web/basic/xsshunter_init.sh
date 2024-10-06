sudo ufw allow 80 && sudo ufw allow 443
sudo apt install docker.io -y; sudo apt install docker-compose -y
mkdir mass_hunt;cd mass_hunt;
git clone https://github.com/mandatoryprogrammer/xsshunter-express; cd xsshunter-express
sudo apt install postgresql -y;
sudo docker-compose up -d postgresdb;
sudo docker-compose up xsshunterexpress;
docker exec -it <container> /bin/bash