#!/usr/bin/env bash



#########################################################

## Twitter Scraper for Psychology Academics

# Ian Hocking Tue, 09 May 2017

## Scans the Twitter feed of this account:

# https://twitter.com/resrchlib_cccu

## Follows mentioned links

## If those links go to pages that match against surnames
## of academics in the Psychology Programme, report it to
## the user

#########################################################






# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

# set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

arg1="${1:-}"

function getLatestUrls () {

	# Look at the RSS feed for the Library Twitter account and find links
	# that are mentioned in the 'title' of the Tweet

	curl -s https://twitrss.me/twitter_user_to_rss/\?user\=resrchlib_cccu | egrep "\<title\>.*\<title\>" | sed 's%;.*%%g' | egrep -o 'https?://[^ ]+' | tr "\n" " " | sed 's/&....//g' 

}

function checkForAcademics () {

	# Scan text (probably a web page) for the appearance of 
	# particular surnames

	pipedInput="$(cat)"

	academicsAll="Pike Abbott Carr Fernandez Franz Hinds Hocking Hulbert Gee Nigbur Osthaus Spruin Vernon Iredale Tsirogianni"

	IFS=', ' read -r -a academic <<< "$academicsAll"

	for index in "${!academic[@]}"

	do

		echo $pipedInput | egrep -q "${academic[index]}" && echo "Found ${academic[index]}"


	done

}



# Get urls from Twitter feed
urlsRaw="$(getLatestUrls)"

# Break URLs into array
IFS=' ' read -r -a url <<< "$urlsRaw"


# Step through URLs
for index in "${!url[@]}"

do

	# Follow the URL and return the raw HTML
	urlFollowedRaw="$(curl -s -L ${url[index]})"

	# Check HTML for surname of any academic
	foundAcademic="$(echo $urlFollowedRaw | checkForAcademics)"

	# Found one? Report it to the user
	if [[ "$foundAcademic" == *"Found"* ]]; then

		echo "$foundAcademic mentioned in this URL: ${url[index]}"

	fi

	foundAcademic=""

done

