#!/bin/sh

#  Created by David Aspinall 
#  Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.

PATH=$PATH:$HOME/bin:/Volumes/BUILD/bin:/usr/local/bin:/Applications/Xcode.app/Contents/Developer/usr/bin/
export PATH

source /Volumes/BUILD/Jenkins/xcode_build/${JOB_NAME}/env.sh
mkdir -p ${WORKSPACE}/gcovr


(
ls -l ${OBJECT_FILE_DIR_normal}

ls -l ${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH}

/usr/local/bin/gcovr --help

echo
echo "XML from workspace"
cd ${WORKSPACE}
/usr/local/bin/gcovr -v -r ${WORKSPACE}/${JOB_NAME} --object-directory ${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH} --xml -o ${WORKSPACE}/gcovr/coverage.1.xml

echo
echo "XML from workspace - relateive"
cd ${WORKSPACE}
/usr/local/bin/gcovr -v -r ${JOB_NAME} --object-directory ${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH} --xml -o ${WORKSPACE}/gcovr/coverage.2.xml

echo
echo "XML from workspace/JOB_NAME"
cd ${WORKSPACE}/${JOB_NAME}
/usr/local/bin/gcovr -v -r ${WORKSPACE}/${JOB_NAME} --object-directory ${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH} --xml -o ${WORKSPACE}/gcovr/coverage.3.xml

echo
echo "XML from workspace/JOB_NAME relative"
cd ${WORKSPACE}/${JOB_NAME}
/usr/local/bin/gcovr -v -r . --object-directory ${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH} --xml -o ${WORKSPACE}/gcovr/coverage.4.xml

echo
echo "XML from object dir"
cd ${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH}
/usr/local/bin/gcovr -v -r ${WORKSPACE}/${JOB_NAME} --xml -o ${WORKSPACE}/gcovr/coverage.5.xml

# echo
# echo "HTML"
# /usr/local/bin/gcovr -v -r ${WORKSPACE}/${JOB_NAME} --object-directory ${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH} --html -o gcovr/coverage.html

) > /tmp/${JOB_NAME}-gcovr.log 2>&1

