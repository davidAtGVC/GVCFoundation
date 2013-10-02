#!/bin/sh

#  Created by David Aspinall 
#  Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.

source /Volumes/BUILD/Jenkins/xcode_build/${JOB_NAME}/env.sh
mkdir -p ${WORKSPACE}/gcovr

(
/usr/local/bin/gcovr --help

echo "XML"
/usr/local/bin/gcovr -r "${WORKSPACE}" --object-directory="${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH}" --xml -o "${WORKSPACE}/gcovr/coverage.xml"

echo "HTML"
/usr/local/bin/gcovr -r "${WORKSPACE}" --object-directory="${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH}" --html -o "${WORKSPACE}/gcovr/coverage.html"

) > /tmp/${JOB_NAME}-gcovr.log 2>&1

