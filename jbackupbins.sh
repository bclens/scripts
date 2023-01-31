echo This will backup Cardano binaries in /usr/local/bin
cd /usr/local/bin
sudo ls # Gives chance to enter password
CLIVERSION=$(cardano-cli version | head -1 | cut -d' ' -f2)
NODEVERSION=$(cardano-node version | head -1 | cut -d' ' -f2)
echo Cli  Version is $CLIVERSION
echo Node Version is $NODEVERSION

echo Backing up...
sudo cp -p cardano-cli cardano-cli.$CLIVERSION
sudo cp -p cardano-node cardano-node.$NODEVERSION
echo Backup completed
ls -l
