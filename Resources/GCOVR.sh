#!/bin/sh

#  Created by David Aspinall 
#  Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.

source /Volumes/BUILD/Jenkins/xcode_build/${JOB_NAME}/env.sh
mkdir -p ${WORKSPACE}/gcovr

/usr/local/bin/gcovr -r ${WORKSPACE} \
        --object-directory ${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH} \
        --xml \ 
        --output ${WORKSPACE}/gcovr/coverage.xml > /tmp/${JOB_NAME}.log 2>&1

/usr/local/bin/gcovr -r ${WORKSPACE} \
        --object-directory ${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH} \
        --html \ 
        --output ${WORKSPACE}/gcovr/coverage.html >> /tmp/${JOB_NAME}.log 2>&1
