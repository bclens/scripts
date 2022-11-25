# This script was made to semi-automate the upgrade process for Cardano.  This has been tested for
# an upgrade from Cardano 1.35.3 to version 1.35.4 for a Coincashew type of manual setup but it may
# also work for future releases as long as there are no major changes.
# I make no guarantees that it will work in your environment so before using this script, 
# please make sure you understand each step and test it first on a test server.  This script has saved me
# a lot of time during my upgrades but I will still manually run each command on a test server to make sure
# all is well before using this on production servers.
###########################################################################################################
# Usage:  bash jupgradenode.sh

echo About to Upgrade Cardano Node
echo ================================================================================
echo Make sure you have backed up your cardano-cli and cardano-node before proceeding
echo -n Press Enter to continue... ; read enter

# Navigate to the folder where you cloned the Cardano Node repository
cd $HOME/git/
git clone https://github.com/input-output-hk/cardano-node.git ./cardano-node2
cd cardano-node2
# Update the list of available packages
cabal update
# Download all branches and tags from the remote repository
git fetch --all --recurse-submodules --tags
# Switch to the branch of the latest Cardano Node release
git checkout $(curl -s https://api.github.com/repos/input-output-hk/cardano-node/releases/latest | jq -r .tag_name)
# Adjust the project configuration to disable optimization and use the recommended compiler version
cabal configure -O0 -w ghc-8.10.7
# Append the cabal.project.local file in the current folder to avoid installing the custom libsodium library
echo -e "package cardano-crypto-praos\n flags: -external-libsodium-vrf" >> cabal.project.local
# Compile the cardano-node and cardano-cli packages found in the current directory
cabal build cardano-node cardano-cli
$(find ./dist-newstyle/build -type f -name "cardano-node") version
$(find ./dist-newstyle/build -type f -name "cardano-cli") version
echo About to Stop Cardano Node
echo -n Press Enter to continue... ; read enter
sudo systemctl stop cardano-node
sudo cp $(find ./dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node
sudo cp $(find ./dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
echo Checking version:
cardano-node version
cardano-cli version
echo Cleaning up directories
cd $HOME/git
mv cardano-node cardano.old
mv cardano-node2 cardano-node
echo Update your config files if required then restart your node for a clean start
