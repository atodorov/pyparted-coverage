#!/usr/bin/bash

DIRNAME=`dirname $0`
JENKINS=$1

if [ -z "$JENKINS" ]; then
    echo "usage: $0 JENKINS_URL"
    exit 1
fi

pushd $DIRNAME

for f in ".coverage" \
        "coverage-report.log"; do

    tgt=`basename $f`
    wget "$JENKINS/job/pyparted-x86_64/lastSuccessfulBuild/artifact/$f" -O "$tgt" 2>/dev/null
    if [ "$?" -ne "0" ]; then
        echo "Downloading $f failed ..."
        git checkout "$tgt"
    fi
done

DATE=`date --rfc-3339=date`
DIFF=`git diff`
# changes detected
if [ -n "$DIFF" ]; then
    git commit -a -m "Updated test results from $DATE"
    git tag "pyparted-$DATE"
    git push --tags origin master
fi

popd
