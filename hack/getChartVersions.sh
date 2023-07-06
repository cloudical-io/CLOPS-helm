#!/bin/bash

### Globals
## CLOPS infos
CLOPS_NAME="clops-helm"
CLOPS_REPO="https://chartmuseum.cloudical.net/clops"
VERSION_FILE="/tmp/versions"
CLOPS_FILE="/tmp/clops_chart"
CLOPS_VALUES_FILE="/tmp/clops_values"

## Table Out
name_width=35
version_width=10
printf "| %-*s | %-*s | %-*s |\n" "$name_width" "CHART NAME" "$version_width" "OLD" "$version_width" "NEW" > "$VERSION_FILE"
printf "| %-*s | %-*s | %-*s |\n" "$name_width" "" "$version_width" "" "$version_width" "" | tr ' ' '-' >> "$VERSION_FILE"

### function definitions
## add chart function
function helm_repo_add () {
	helm repo add $1 $2 2>&1 > /dev/null
}

function print_header() {
	printf "| %-*s |\n" "75" | tr ' ' '#'
	printf "# %-*s%*s #\n" "25" "$1" "25"
	printf "| %-*s |\n" "75" | tr ' ' '#'
}

function print_divider() {
	printf "| %-*s |\n" "75" | tr ' ' '-'
}

## Add CLOPS Helm repository
helm_repo_add "$CLOPS_NAME" "$CLOPS_REPO"

## Print clops infos to files
helm show chart "$CLOPS_NAME/$CLOPS_NAME" | yq '.dependencies' > "$CLOPS_FILE"
helm show values "$CLOPS_NAME/$CLOPS_NAME" > "$CLOPS_VALUES_FILE"

LIST_LENGTH=`helm show chart "$CLOPS_NAME/$CLOPS_NAME" | yq '.dependencies | length'`
for i in $(seq 0 `echo $(($LIST_LENGTH - 1))`)
do
	CLOPS_TMP_FILE="/tmp/tmp_value.yaml"
	COMPARE_NEW_TMP_FILE="/tmp/compare_new_value.yaml"
	COMPARE_OLD_TMP_FILE="/tmp/compare_old_value.yaml"

	## Adding chart repositories
	NAME=`cat "$CLOPS_FILE" | yq e ".[$i].name"`;
	REPO=`cat "$CLOPS_FILE" | yq e ".[$i].repository"`;
	helm_repo_add "$NAME" "$REPO"

	VERSION_OLD=`cat "$CLOPS_FILE" | yq e ".[$i].version"`
	VERSION_NEW=`helm show chart "$NAME/$NAME" | yq '.version'`
	VERSION_NEW=`helm show chart "$NAME/$NAME" | yq '.version'`

	## append to table
	printf "| %-*s | %-*s | %-*s |\n" "$name_width" "$NAME" "$version_width" "$VERSION_OLD" "$version_width" "$VERSION_NEW" >> "$VERSION_FILE"

	helm show values "$NAME/$NAME" --version "$VERSION_NEW" > "$COMPARE_NEW_TMP_FILE"
	helm show values "$NAME/$NAME" --version "$VERSION_OLD" > "$COMPARE_OLD_TMP_FILE"

	cat "$CLOPS_VALUES_FILE" | yq e ".$NAME" > "$CLOPS_TMP_FILE"

	## VARS
	VALUES_TMP="/tmp/diff"
	VALUES_TMP_NEW="/tmp/diff_new"

	print_header "$NAME additions"

	python3 get_yaml_diff.py "$COMPARE_OLD_TMP_FILE" "$COMPARE_NEW_TMP_FILE" > "$VALUES_TMP"
	python3 get_yaml_diff.py "$CLOPS_TMP_FILE" "$VALUES_TMP" > "$VALUES_TMP_NEW"
	yq 'del(.enabled)' "$VALUES_TMP_NEW"

	print_divider

	VALUES_TMP="/tmp/diff"
	VALUES_TMP_NEW="/tmp/diff_new"
	python3 get_yaml_removals.py "$COMPARE_OLD_TMP_FILE" "$COMPARE_NEW_TMP_FILE" | yq 'del(.add_or_change)' > "$VALUES_TMP"
	yq 'del(.enabled)' "$VALUES_TMP"

	print_divider
done

cat "$VERSION_FILE"
