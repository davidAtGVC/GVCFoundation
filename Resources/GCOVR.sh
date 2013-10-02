#!/bin/sh

#  Created by David Aspinall 
#  Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.

cd ${WORKSPACE}
source /Volumes/BUILD/Jenkins/xcode_build/${JOB_NAME}/env.sh
mkdir -p ${WORKSPACE}/gcovr

(
/usr/local/bin/gcovr --help

echo
echo "XML"
/usr/local/bin/gcovr -r . --object-directory="${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH}" --xml --gcov-executable=/usr/local/bin/gcovr -o "gcovr/coverage.xml"

echo
echo "HTML"
/usr/local/bin/gcovr -r . --object-directory="${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH}" --html --gcov-executable=/usr/local/bin/gcovr -o "gcovr/coverage.html"

) > /tmp/${JOB_NAME}-gcovr.log 2>&1

