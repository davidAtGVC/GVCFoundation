#!/bin/sh

#  BuildKitHeader.sh
#  GVCFoundation
#
#  Created by David Aspinall on 11-10-02.
#  Copyright (c) 2011 Global Village Consulting Inc. All rights reserved.


printHeader()
{
    echo "/**"
    echo " * Header for $1"
    echo " */" 
	echo
	echo "#ifndef $1_h"
	echo "#define $1_h"
	echo
}


printFooter()
{
	echo
	echo "#endif // $1_h"

}

HEADER=$PRODUCT_NAME/${PRODUCT_NAME}.h
TEMP=$PRODUCT_NAME/${PRODUCT_NAME}.tmp

# check for old temporary header
if [ -f $TEMP ]; then
	echo removing $TEMP
	rm -f $TEMP
fi

# generate new framework header as a temporary file
(
	printHeader $PRODUCT_NAME

    SEDS="s/^$PRODUCT_NAME\///"
    find $PRODUCT_NAME -name \*.h ! -name $PRODUCT_NAME.h | \
        sed "$SEDS" | sort | \
        awk 'BEGIN {FS="/"} \
            { F=$NF; $NF=""; if ( BASE"" != $0 ) { printf "\n/* \n * %s\n */\n", $0; BASE=$0 } } \
            { printf "#import \"%s\"\n", F}'

    printFooter $PRODUCT_NAME
) > "${TEMP}"

# If the new and old files are identical, then don't replace
if [ -f $HEADER ]; then
	diff -q ${HEADER} ${TEMP}
	if [ $? -ne 0 ]; then
		echo "Different framework header .. replacing"
		rm ${HEADER}
		mv ${TEMP} ${HEADER}
	else
		echo "Framework header unchanged"
		if [ -f $TEMP ]; then
			rm -f $TEMP
		fi
	fi
else
	mv ${TEMP} ${HEADER}
fi

