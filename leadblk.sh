#!/bin/bash
# This script (leadcheck.sh) was created by WISH Pool and may be distributed
# and modified freely as long as this header section is kept intact.
# The script uses the native cardano-cli executable to calculate leaderlogs.
# You do not need to maintain any database.  You only need the native cardano
# executable cardano-cli.  This should ensure that the script will work with
# future Cardano releases unless there are breaking changes
#############################################################################
# Usage-> To use this script, do the following:
# - Update the variables in the CONFIGURATION section below
# - Create the $DIRECTORY/leader directory (if it is not existing)
# - Copy your vrf.skey onto the $DIRECTORY/leader directory
# - Copy this script to a file called leadcheck.sh in $DIRECTORY/leader
# - Run the script: bash leadcheck.sh
####################### CONFIGURATION Section ###############################
# Update variables below as required:
DIRECTORY=/home/cardano/cardano-my-node
STAKE_POOL_ID=4dbdfb68de96a563719f7df2b3cf7c98fb547a3e7edca2a547d35852
LOCALTZ=Asia/Singapore
NETWORK=mainnet  # You can change this to "preview" or "preprod" also
PERIOD=current   # Set PERIOD to "current", "next" or "previous" 
                 # depending on what period you want to check leaderlogs
#################### End of CONFIGURATION Section ###########################
date
EPOCH=$(cardano-cli query tip --$NETWORK | jq -r '.epoch')
echo Starting leadership checks for epoch $EPOCH

cardano-cli query leadership-schedule \
--$NETWORK \
--genesis "$DIRECTORY/$NETWORK-shelley-genesis.json" \
--stake-pool-id $STAKE_POOL_ID \
--vrf-signing-key-file "$DIRECTORY/leader/vrf.skey" \
--$PERIOD | tee leaderUTC.out

date
echo
echo Updating to local time zone
tail +3 leaderUTC.out > ltemp.txt
FILE=ltemp.txt
while read LINE; do
  SLOT=$(echo $LINE | cut -f1 -d' ')
  WHEN=$(echo $LINE | cut -f2- -d' ')
  echo -n Slot: $SLOT On: 
  TZ=$LOCALTZ date -d "$WHEN" +'%s, %F %T %Z %z'
done < "$FILE" | tee leadblk-$EPOCH.out
rm $FILE
echo Output is stored in leadblk-$EPOCH.out for future reference.
