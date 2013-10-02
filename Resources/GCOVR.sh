#!/bin/sh

#  Created by David Aspinall 
#  Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.

PATH=$PATH:$HOME/bin:/Volumes/BUILD/bin:/usr/local/bin:/Applications/Xcode.app/Contents/Developer/usr/bin/
export PATH

cd ${WORKSPACE}
source /Volumes/BUILD/Jenkins/xcode_build/${JOB_NAME}/env.sh
mkdir -p ${WORKSPACE}/gcovr

ls -l ${OBJECT_FILE_DIR_normal}

ls -l ${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH}

(
/usr/local/bin/gcovr --help

echo
echo "XML"
/usr/local/bin/gcovr -r ${WORKSPACE}/${JOB_NAME} --object-directory ${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH} --xml -o gcovr/coverage.xml

echo
echo "HTML"
/usr/local/bin/gcovr -r ${WORKSPACE}/${JOB_NAME} --object-directory ${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH} --html -o gcovr/coverage.html

) > /tmp/${JOB_NAME}-gcovr.log 2>&1

