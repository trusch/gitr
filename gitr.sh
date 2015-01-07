#!/bin/bash

GITRPREFIX="gitr"

function currentBranch {
	git branch | egrep "^\*" | cut -d' ' -f2
}

function currentVariant {
	currentBranch | cut -d'/' -f2
}

function currentType {
	currentBranch | cut -d'/' -f3
}

function currentFeature {
	currentBranch | cut -d'/' -f4-
}

function allBranches {
	git branch | egrep "$GITRPREFIX/" |sed s/' '//g|sed s/'*'//g|tr '\n' ' '
}

function allExperimental {
	git branch | egrep "$GITRPREFIX/.*/experimental" |sed s/' '//g|sed s/'*'//g|tr '\n' ' '
}

function allTesting {
	git branch | egrep "$GITRPREFIX/.*/testing" |sed s/' '//g|sed s/'*'//g|tr '\n' ' '
}

function allStable {
	git branch | egrep "$GITRPREFIX/.*/stable" |sed s/' '//g|sed s/'*'//g|tr '\n' ' '
}

function allVariants {
	git branch | egrep "$GITRPREFIX/.*/stable" |cut -d/ -f2
}

function allFeatures {
	git branch | egrep "$GITRPREFIX/.*/feature/" |cut -d/ -f2,4
}

function allHotfixes {
	git branch | egrep "$GITRPREFIX/.*/hotfix/" |cut -d/ -f2,4
}

function allColdfixes {
	git branch | egrep "$GITRPREFIX/.*/coldfix/" |cut -d/ -f2,4
}

function currentFeatures {
	git branch | egrep "$GITRPREFIX/$(currentVariant)/feature/" |cut -d/ -f4-
}

function currentHotfixes {
	git branch | egrep "$GITRPREFIX/$(currentVariant)/hotfix/" |cut -d/ -f4-
}

function currentColdfixes {
	git branch | egrep "$GITRPREFIX/$(currentVariant)/coldfix/" |cut -d/ -f4-
}

# createVariant <variant>
function createVariant {
	VARIANT=$1
	git checkout -b $GITRPREFIX/$VARIANT/experimental 2>/dev/null
	git checkout -b $GITRPREFIX/$VARIANT/testing 2>/dev/null
	git checkout -b $GITRPREFIX/$VARIANT/stable 2>/dev/null
	
	git checkout $GITRPREFIX/$VARIANT/experimental 2>/dev/null
	echo "checked out variant $VARIANT."
}

# createFeature <variant> <feature>
function createFeature {
	VARIANT=$1
	FEATURE=$2
	git checkout -b $GITRPREFIX/$VARIANT/feature/$FEATURE 2>/dev/null || \
		git checkout $GITRPREFIX/$VARIANT/feature/$FEATURE 2>/dev/null
	echo "checked out feature $FEATURE for variant $VARIANT"
}

# createHotfix <variant> <hotfix>
function createHotfix {
	VARIANT=$1
	HOTFIX=$2
	git checkout -b $GITRPREFIX/$VARIANT/hotfix/$HOTFIX 2>/dev/null || \
		git checkout $GITRPREFIX/$VARIANT/hotfix/$HOTFIX 2>/dev/null
	echo "checked out hotfix $HOTFIX for variant $VARIANT"
}

# createColdfix <variant> <coldfix>
function createColdfix {
	VARIANT=$1
	COLDFIX=$2
	git checkout -b $GITRPREFIX/$VARIANT/coldfix/$COLDFIX 2>/dev/null || \
		git checkout $GITRPREFIX/$VARIANT/coldfix/$COLDFIX 2>/dev/null
	echo "checked out coldfix $COLDFIX for variant $VARIANT"
}

function upmerge {
	VARIANT=$(currentVariant)
	TYPE=$(currentType)
	FEATURE=$(currentFeature)
	SOURCEBRANCH=$(currentBranch)
	case $TYPE in 
		"feature")
			if [[ $VARIANT != 'universal' ]]; then
				git checkout $GITRPREFIX/$VARIANT/experimental 2>&1 >/dev/null
				git merge $SOURCEBRANCH 2>&1 >/dev/null || exit 1
				echo "upmerged feature $FEATURE into $VARIANT/experimental"
			else
				for exp in $(allExperimental); do
					git checkout $exp 2>&1 >/dev/null
					git merge $SOURCEBRANCH 2>&1 >/dev/null || exit 1
					echo "upmerged feature $FEATURE into $(currentVariant)/experimental"
				done
			fi		
		;;
		"experimental")
			if [[ $VARIANT != 'universal' ]]; then
				git checkout $GITRPREFIX/$VARIANT/testing 2>&1 >/dev/null
				git merge $SOURCEBRANCH 2>&1 >/dev/null || exit 1
				echo "upmerged $VARIANT/experimental into $VARIANT/testing"
			else
				for exp in $(allTesting); do
					git checkout $exp 2>&1 >/dev/null
					git merge $SOURCEBRANCH 2>&1 >/dev/null || exit 1
					echo "upmerged universal/experimental into $(currentVariant)/testing"
				done
			fi
		;;
		"testing")
			if [[ $VARIANT != 'universal' ]]; then
				git checkout $GITRPREFIX/$VARIANT/stable 2>&1 >/dev/null
				git merge $SOURCEBRANCH 2>&1 >/dev/null || exit 1
				echo "upmerged $VARIANT/testing into $VARIANT/stable"
			else
				for exp in $(allTesting); do
					git checkout $exp 2>&1 >/dev/null
					git merge $SOURCEBRANCH 2>&1 >/dev/null || exit 1
					echo "upmerged universal/testing into $(currentVariant)/stable"
				done
			fi
		;;
		"hotfix")
			if [[ $VARIANT != 'universal' ]]; then
				git checkout $GITRPREFIX/$VARIANT/stable 2>&1 >/dev/null
				git merge $SOURCEBRANCH 2>&1 >/dev/null || exit 1
				echo "upmerged $VARIANT/hotfix/$FEATURE into $VARIANT/stable"
				git checkout $GITRPREFIX/$VARIANT/testing 2>&1 >/dev/null
				git merge $SOURCEBRANCH 2>&1 >/dev/null || exit 1
				echo "upmerged $VARIANT/hotfix/$FEATURE into $VARIANT/testing"
				git checkout $GITRPREFIX/$VARIANT/experimental 2>&1 >/dev/null
				git merge $SOURCEBRANCH 2>&1 >/dev/null || exit 1
				echo "upmerged $VARIANT/hotfix/$FEATURE into $VARIANT/experimental"
			else
				echo "NOTICE: You must merge this hotfix into the target stable branch by hand!"
				for exp in $(allExperimental); do
					git checkout $exp 2>&1 >/dev/null
					git merge $SOURCEBRANCH 2>&1 >/dev/null || exit 1
					echo "upmerged universal/hotfix/$FEATURE into $(currentVariant)/experimental"
				done
			fi
		;;
		"coldfix")
			if [[ $VARIANT != 'universal' ]]; then
				git checkout $GITRPREFIX/$VARIANT/testing 2>&1 >/dev/null
				git merge $SOURCEBRANCH 2>&1 >/dev/null || exit 1
				echo "upmerged $VARIANT/hotfix/$FEATURE into $VARIANT/testing"
				git checkout $GITRPREFIX/$VARIANT/experimental 2>&1 >/dev/null
				git merge $SOURCEBRANCH 2>&1 >/dev/null || exit 1
				echo "upmerged $VARIANT/hotfix/$FEATURE into $VARIANT/experimental"
			else
				echo "NOTICE: You must merge this coldfix into the target testing branch by hand!"
				for exp in $(allExperimental); do
					git checkout $exp 2>&1 >/dev/null
					git merge $SOURCEBRANCH 2>&1 >/dev/null || exit 1
					echo "upmerged universal/coldfix/$FEATURE into $(currentVariant)/experimental"
				done
			fi
		;;
	esac
	git checkout $SOURCEBRANCH 2>&1 >/dev/null
}

function update {
	VARIANT=$(currentVariant)
	TYPE=$(currentType)
	FEATURE=$(currentFeature)
	SOURCEBRANCH=$(currentBranch)
	case $TYPE in 
		"feature")
			git merge $GITRPREFIX/$VARIANT/experimental 2>&1 >/dev/null || exit 1
			echo "merged $VARIANT/experimental into feature $FEATURE"
		;;
		"experimental")
			git merge $GITRPREFIX/$VARIANT/stable  2>&1 >/dev/null || exit 1
			echo "merged $VARIANT/stable into $VARIANT/experimental"

			git merge $GITRPREFIX/$VARIANT/testing  2>&1 >/dev/null || exit 1
			echo "merged $VARIANT/testing into $VARIANT/experimental"

			features=$(allFeatures|egrep "^$VARIANT"|cut -d/ -f2)
			for feature in $features; do
				git merge $GITRPREFIX/$VARIANT/feature/$feature 2>&1 >/dev/null || exit 1
				echo "merged feature $feature into $VARIANT/experimental"
			done
			features=$(allFeatures|egrep "^universal"|cut -d/ -f2)
			for feature in $features; do
				git merge $GITRPREFIX/universal/feature/$feature 2>&1 >/dev/null || exit 1
				echo "merged feature universal/$feature into $VARIANT/experimental"
			done
			coldfixes=$(allColdfixes|egrep "^$VARIANT"|cut -d/ -f2)
			coldfixes+=$(allColdfixes|egrep "^universal"|cut -d/ -f2)
			for coldfix in $coldfixes; do
				git merge $GITRPREFIX/$VARIANT/coldfix/$coldfix 2>&1 >/dev/null || exit 1
				echo "merged coldfix $coldfix into $VARIANT/experimental"
			done
		;;
		"stable")
			hotfixes=$(allHotfixes|egrep "^$VARIANT"|cut -d/ -f2)
			for hotfix in $hotfixes; do
				git merge $GITRPREFIX/$VARIANT/hotfix/$hotfix 2>&1 >/dev/null || exit 1
				echo "merged hotfix $hotfix into $VARIANT/stable"
			done
		;;
		"testing")
			coldfixes=$(allHotfixes|egrep "^$VARIANT"|cut -d/ -f2)
			for coldfix in $coldfixes; do
				git merge $GITRPREFIX/$VARIANT/coldfix/$coldfix 2>&1 >/dev/null || exit 1
				echo "merged coldfix $coldfix into $VARIANT/testing"
			done
		;;
		"hotfix")
			git merge $GITRPREFIX/$VARIANT/stable 2>&1 >/dev/null || exit 1
			echo "merged $VARIANT/stable into hotfix $FEATURE"			
		;;
		"coldfix")
			git merge $GITRPREFIX/$VARIANT/testing 2>&1 >/dev/null || exit 1
			echo "merged $VARIANT/experimental into coldfix $FEATURE"
		;;
	esac
}

function init {
	VARIANT=$(currentVariant)
	TYPE=$(currentType)
	FEATURE=$(currentFeature)
	SOURCEBRANCH=$(currentBranch)
	case $TYPE in 
		"feature"|"experimental"|"hotfix"|"coldfix")
			update ;;
		"stable")
			git merge $GITRPREFIX/$VARIANT/testing 2>&1 >/dev/null || exit 1
			echo "merged $VARIANT/testing into $VARIANT/stable"	
		;;
		"testing")
			git merge $GITRPREFIX/$VARIANT/experimental 2>&1 >/dev/null || exit 1
			echo "merged $VARIANT/experimental into $VARIANT/testing"		
		;;
	esac	
}

# command_variant <variant>
function command_variant {
	if [[ $# -lt 1 ]]; then exit 1; fi
	createVariant $1
}

# command_feature <feature> <variant>
function command_feature {
	if [[ $# -lt 1 ]]; then exit 1; fi
	FEATURE=$1
	VARIANT=$2
	if [[ "foo$VARIANT" == "foo" ]]; then
		VARIANT=$(currentVariant)
	fi
	createFeature $VARIANT $FEATURE
}

# command_feature <hotfix> <variant>
function command_hotfix {
	if [[ $# -lt 1 ]]; then exit 1; fi
	FEATURE=$1
	VARIANT=$2
	if [[ "foo$VARIANT" == "foo" ]]; then
		VARIANT=$(currentVariant)
	fi
	createHotfix $VARIANT $FEATURE
}

# command_feature <coldfix> <variant>
function command_coldfix {
	if [[ $# -lt 1 ]]; then exit 1; fi
	FEATURE=$1
	VARIANT=$2
	if [[ "foo$VARIANT" == "foo" ]]; then
		VARIANT=$(currentVariant)
	fi
	createColdfix $VARIANT $FEATURE
}

function command_ls {
	CURRENTVARIANT=""
	FIRSTFEATURE=1
	FIRSTHOTFIX=1
	FIRSTCOLDFIX=1
	for branch in $(allBranches); do 
		VARIANT=$(echo $branch|cut -d/ -f2)
		TYPE=$(echo $branch|cut -d/ -f3)
		ID=$(echo $branch|cut -d/ -f4-)
		if [[ $VARIANT != $CURRENTVARIANT ]]; then
			CURRENTVARIANT=$VARIANT
			FIRSTFEATURE=1
			FIRSTHOTFIX=1
			FIRSTCOLDFIX=1
			echo "  $VARIANT/"
			if [[ $(currentBranch) == $branch && $TYPE == "experimental" ]]; then
				echo "*   experimental"
			else
				echo "    experimental"
			fi
			if [[ $(currentBranch) == $branch && $TYPE == "testing" ]]; then
				echo "*   testing"
			else
				echo "    testing"
			fi
			if [[ $(currentBranch) == $branch && $TYPE == "stable" ]]; then
				echo "*   stable"
			else
				echo "    stable"
			fi
		fi
		case $TYPE in 
			"experimental");;
			"stable");;
			"feature")
				if [[ $FIRSTFEATURE == 1 ]]; then
					FIRSTFEATURE=0
					echo "    feature/"
				fi
				if [[ $(currentBranch) == $branch ]]; then
					echo "*       $ID"
				else
					echo "        $ID"
				fi;;
			"hotfix")
				if [[ $FIRSTHOTFIX == 1 ]]; then
					FIRSTHOTFIX=0
					echo "    hotfix/"
				fi
				if [[ $(currentBranch) == $branch ]]; then
					echo "*       $ID"
				else
					echo "        $ID"
				fi;;
			"coldfix")
				if [[ $FIRSTCOLDFIX == 1 ]]; then
					FIRSTCOLDFIX=0
					echo "    coldfix/"
				fi
				if [[ $(currentBranch) == $branch ]]; then
					echo "*       $ID"
				else
					echo "        $ID"
				fi;;		
		esac
	done
}

function help {
	echo -e "usage: $0"
	echo -e "\tvariant <variant>             # checkout variant"
	echo -e "\tfeature <feature> [<variant>] # checkout feature"
	echo -e "\thotfix <hotfix> [<variant>]	 # checkout hotfix"
	echo -e "\tcoldfix <coldfix> [<variant>] # checkout coldfix"
	echo -e "\tupmerge                       # upmerge to correct destinations"
	echo -e "\tupdate                        # fetch commits from the correct sources"
	echo -e "\tinit                          # init stable or testing from underlying layer"
}

COMMAND=$1
shift
case $COMMAND in 
	"variant")      command_variant   $*;;
	"feature")      command_feature   $*;;
	"hotfix")       command_hotfix    $*;;
	"coldfix")      command_coldfix   $*;;
	"upmerge")      upmerge 			;;
	"update")       update 			    ;;
	"init")         init			    ;;
	"experimental") git checkout $GITRPREFIX/$(currentVariant)/experimental;;
	"testing")      git checkout $GITRPREFIX/$(currentVariant)/testing;;
	"stable")       git checkout $GITRPREFIX/$(currentVariant)/stable;;
	"variants")     allVariants;;
	"features")     currentFeatures;;
	"hotfixes")     currentHotfixes;;
	"coldfixes")    currentColdfixes;;
	"ls")			command_ls;;
	"rm")			git branch -d $GITRPREFIX/$1;;
	"help")         help $*;;
	*) help && exit 1;;
esac
