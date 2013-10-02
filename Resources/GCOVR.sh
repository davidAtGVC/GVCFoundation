#!/bin/sh

#  Created by David Aspinall 
#  Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.

PATH=$PATH:$HOME/bin:/Volumes/BUILD/bin:/usr/local/bin:/Applications/Xcode.app/Contents/Developer/usr/bin/
export PATH

source /Volumes/BUILD/Jenkins/xcode_build/${JOB_NAME}/env.sh
mkdir -p ${WORKSPACE}/gcovr

(
# /usr/local/bin/gcovr --help
cd ${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH}

echo
echo "XML"
/usr/local/bin/gcovr -r ${WORKSPACE}/${JOB_NAME} --xml -o ${WORKSPACE}/gcovr/coverage.xml

echo
echo "HTML"
/usr/local/bin/gcovr -r ${WORKSPACE}/${JOB_NAME} --html -o ${WORKSPACE}/gcovr/coverage.html

) > /tmp/${JOB_NAME}-gcovr.log 2>&1

