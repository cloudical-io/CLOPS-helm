#!/bin/sh

### Globals
## CLOPS infos
CLOPS_NAME="clops-helm"
CLOPS_REPO="https://chartmuseum.cloudical.net/clops"
VERSION_FILE="/tmp/versions"
CLOPS_FILE="/tmp/clops_chart"
CLOPS_TMP_FILE="/tmp/clops_chart_tmp"
CLOPS_VALUES_FILE="/tmp/clops_values"
SELECTED_NEW_VALUES="/tmp/GEN_CHART"
SELECTED_OLD_VALUES="/tmp/GEN_CHART_OLD"

### function definitions
## add chart function
function helm_repo_add () {
	helm repo add $1 $2 2>&1 > /dev/null
    helm repo update 2>&1 > /dev/null
}

## Add CLOPS Helm repository
helm_repo_add "$CLOPS_NAME" "$CLOPS_REPO"

read_input() {
    read RESULT
    printf "$RESULT"
}

print_divider () {
     printf "%-*s\n" "60" "" | tr ' ' '-'
}

get_chart_in_version() {
    print_divider
    printf "\tEnter the %s version you want \n\tin Format 'X.Y.Z', 'X.Y.*' or 'X.Y'\n\tChoice > " "$1"
    V=`read_input`
    printf "\n\tRequesting Chart %s in Version %s\n" "$1" "$V"
    FETCH_V=`helm show chart "$1/$1" --version "$V" 2>/dev/null | yq '.version'`
    helm show values "$1/$1" --version "$V" > "$SELECTED_NEW_VALUES" \
        && printf "\tFound Version %s\n" "$FETCH_V" \
        || get_chart_in_version $1
}

print_dependencies() {
    LIST_LENGTH=`cat "$CLOPS_FILE" | yq '. | length'`
    print_divider
    printf "\tSelect the chart you want to compare\n"
    print_divider
    for i in $(seq 0 `echo $(($LIST_LENGTH - 1))`)
    do
        printf "\t%s. Chart: %s \n" "$i" `cat "$CLOPS_FILE" | yq e ".[$i].name"`
    done
    print_divider
}

## Print clops infos to files
helm show chart "$CLOPS_NAME/$CLOPS_NAME" | yq '.dependencies' > "$CLOPS_FILE"
helm show values "$CLOPS_NAME/$CLOPS_NAME" > "$CLOPS_VALUES_FILE"

print_dependencies

printf "\tChoice > "
C=`read_input`
while [[ $C -gt $LIST_LENGTH || $C -lt 0 ]]; do
    printf "\tSelection must be between 0 and %d \n" "$C"
    printf "\tChoice > "
    C=`read_input`
done

SELECTION_NAME=`cat "$CLOPS_FILE" | yq e ".[$C].name"`
SELECTION_REPO=`cat "$CLOPS_FILE" | yq e ".[$C].repository"`
SELECTION_VERS=`cat "$CLOPS_FILE" | yq e ".[$C].version"`

helm_repo_add $SELECTION_NAME $SELECTION_REPO

SELECTION_UPDA=`helm show chart "$SELECTION_NAME/$SELECTION_NAME" | yq '.version'`

printf "\n\t%s current version is %s \n\tNewest available is %s\n" "$SELECTION_NAME" "$SELECTION_VERS" "$SELECTION_UPDA"
print_divider

get_chart_in_version $SELECTION_NAME

print_divider
print_divider

###
### Diff Selected Versions to current chart
###
helm show values "$SELECTION_NAME/$SELECTION_NAME" --version "$SELECTION_VERS" > "$SELECTED_OLD_VALUES"

cat "$CLOPS_VALUES_FILE" | yq e ".$SELECTION_NAME" > "$CLOPS_TMP_FILE"

## VARS
VALUES_TMP="/tmp/diff"
VALUES_TMP_NEW="/tmp/diff_new"

python3 get_yaml_diff.py "$SELECTED_OLD_VALUES" "$SELECTED_NEW_VALUES" > "$VALUES_TMP"
python3 get_yaml_diff.py "$CLOPS_TMP_FILE" "$VALUES_TMP" > "$VALUES_TMP_NEW"
yq 'del(.enabled)' "$VALUES_TMP_NEW"

print_divider

