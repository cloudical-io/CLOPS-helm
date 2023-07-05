#!/bin/bash

### Globals
## CLOPS infos
CLOPS_NAME="clops-helm"
CLOPS_REPO="https://chartmuseum.cloudical.net/clops"
VERSION_FILE="/tmp/versions"
CLOPS_FILE="/tmp/clops_chart"
## Table Out
name_width=35
version_width=10
printf "| %-*s | %-*s | %-*s |\n" "$name_width" "CHART NAME" "$version_width" "OLD" "$version_width" "NEW" > "$VERSION_FILE"
printf "| %-*s | %-*s | %-*s |\n" "$name_width" "" "$version_width" "" "$version_width" "" | tr ' ' '-' >> "$VERSION_FILE"

### function definitions
## add chart function
function helm_repo_add () {
	helm repo add $1 $2 2&>1 > /dev/null
}

# Pass the version difference 
function get_version_differences () {}

## Add CLOPS Helm repository
helm_repo_add "$CLOPS_NAME" "$CLOPS_REPO"
## Print clops helm to file
helm show chart "$CLOPS_NAME/$CLOPS_NAME" | yq '.dependencies' > "$CLOPS_FILE"

LIST_LENGTH=`helm show chart "$CLOPS_NAME/$CLOPS_NAME" | yq '.dependencies | length'`
for i in $(seq 0 `echo $(($LIST_LENGTH - 1))`)
do
	## Adding chart repositories
	NAME=`cat "$CLOPS_FILE" | yq e ".[$i].name"`;
	REPO=`cat "$CLOPS_FILE" | yq e ".[$i].repository"`;
	helm_repo_add "$NAME" "$REPO"


	VERSION_OLD=`cat "$CLOPS_FILE" | yq e ".[$i].version"`
	VERSION_NEW=`helm show chart "$NAME/$NAME" | yq '.version'`

	## append to table
	printf "| %-*s | %-*s | %-*s |\n" "$name_width" "$NAME" "$version_width" "$VERSION_OLD" "$version_width" "$VERSION_NEW" >> "$VERSION_FILE"
done

cat "$VERSION_FILE"
