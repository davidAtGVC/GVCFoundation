#!/bin/sh

#  Created by David Aspinall 
#  Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.

source /Volumes/BUILD/Jenkins/xcode_build/${JOB_NAME}/env.sh
mkdir -p ${WORKSPACE}/gcovr

(
gcovr --help

echo "XML"
gcovr -r ${WORKSPACE} --object-directory=${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH} --xml -o ${WORKSPACE}/gcovr/coverage.xml

echo "HTML"
gcovr -r ${WORKSPACE} --object-directory=${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH} --html -o ${WORKSPACE}/gcovr/coverage.html

) > /tmp/${JOB_NAME}-gcovr.log 2>&1

