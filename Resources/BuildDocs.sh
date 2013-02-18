#! /bin/sh

if [ "${PROJECT_DIR}" == "" ]; then
	PROJECT_DIR=`dirname $0`/..
fi

/usr/local/bin/appledoc \
	--project-name "GVCFoundation" \
	--project-company "Global Village Consulting" \
	--company-id "net.global-village" \
	--create-html \
	--docset-atom-filename "GVCFoundation.atom" \
	--docset-feed-url "http://global-village.net/GVCFoundation/%DOCSETATOMFILENAME" \
	--docset-package-url "http://global-village.net/GVCFoundation/%DOCSETPACKAGEFILENAME" \
	--docset-fallback-url "http://global-village.net/GVCFoundation/" \
	--output "~/Sites/GVCFoundation" \
	--publish-docset \
	--exit-threshold 2 \
	--logformat xcode \
	--keep-undocumented-objects \
	--keep-undocumented-members \
	--keep-intermediate-files \
	--no-repeat-first-par \
	--no-warn-invalid-crossref \
	--ignore "*.m" \
	--logformat xcode \
	--templates "${PROJECT_DIR}/Resources/Documentation/appledoc" \
	--index-desc "${PROJECT_DIR}/Resources/Licenses/GVC License.md" \
	--verbose 2 \
	--exit-threshold 2 \
	"${PROJECT_DIR}/GVCFoundation"
