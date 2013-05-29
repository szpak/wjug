#!/bin/bash
###############################################################
# procedures
###############################################################

verifyAnyChangesAreToBeCommitted() {
    gitCommitStatus=$(git status --porcelain)
    if [ "$gitCommitStatus" == "" ]; then
        startPrintingRed
        echo "Nothing new in here. Returning to master without a commit (including hard reset)."
        stopColloringEcho
        cleanAndReturnToMaster
        exit 1
    fi

    echo "Found changes to be committed."
}

cleanAndReturnToMaster() {
    git reset --hard
    git checkout master
}

verifyEverythingIsCommited() {
    gitCommitStatus=$(git status --porcelain)
    if [ "$gitCommitStatus" != "" ]; then
        startPrintingRed
        echo "You have uncommited files."
        echo "Your git status:"
        echo $gitCommitStatus
        echo "Sorry. Rules are rules. Aborting!"
        stopColloringEcho
        exit 1
    fi
}

verifyEverythingIsPushedToOrigin() {
    gitPushStatus=$(git cherry -v)
    if [ "$gitPushStatus" != "" ]; then
        startPrintingRed
        echo "You have local commits that were NOT pushed."
        echo "Your 'git cherry -v' status:"
        echo $gitPushStatus
        echo "Sorry. Rules are rules. Aborting!"
        stopColloringEcho
        exit 1
    fi
}

startPrintingYellow() {
    echo -e "\e[01;33m"
}

startPrintingRed() {
    echo -e "\e[01;31m"
}

stopColloringEcho() {
    echo -n -e '\e[00m'
}

###############################################################
# work starts here
###############################################################

# sanity check
#verifyEverythingIsCommited
#verifyEverythingIsPushedToOrigin

# pull from master
git checkout master
git pull origin master
currentHasOnMaster=$(git rev-parse HEAD)

# fire up nodejs and generate _public
startPrintingYellow
echo "================================================================================"
echo "> Firing up nodejs. Ctrl+c when generations is finished."
echo "> (a pull request to automatize it would be welcome)"
echo "================================================================================"
stopColloringEcho

./scripts/server.sh

# checkout gh-pages
git checkout gh-pages

# override content
cp -r _public/*

# if anything new
verifyAnyChangesAreToBeCommitted

# add & commit & push

git add .
echo 'autoupdate to $currentHasOnMaster '
#git commit -m 'autoupdate to $currentHasOnMaster '
#git push origin gh-pages

# checkout master
##cleanAndReturnToMaster

startPrintingYellow
echo "================================================================================"
echo "Update finished. Thank you for cooperation."
echo "================================================================================"
stopColloringEcho