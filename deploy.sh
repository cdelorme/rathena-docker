#!/bin/bash -eu

# exit if docker does not exist
if ! which docker; then echo "docker required..." && exit 1; fi


##
# define helper functions
##

grab()
{
	[ -n "$(eval echo \${$1:-})" ] && return 0
	export ${1}=""
	read -t 30 -p "${2:-input}: " ${1}
	# while [ -z "$(eval echo \$$1)" ]; do
	# done
	return 0
}

grab_yes_no()
{
	[[ "$(eval echo \${$1:-})" = "y" || "$(eval echo \${$1:-})" = "n" ]] && return 0
	export ${1}=""
	until [[ "$(eval echo \$$1)" = "y" || "$(eval echo \$$1)" = "n" ]]; do
		read -p "${2:-} (yn)? " ${1}
	done
	return 0
}


##
# begin asking for inputs
##

# check if image exists by name
[ $(docker ps -qaf "name=single-target" | wc -l) -gt 0 ] && export single_exists=0 && export deployment_method="none"
# @todo: check for distributed

# @todo: cleaner separation of queries move existence handlers here
if [ ${single_exists:-1} -eq 0 ]; then
	grab_yes_no "teardown" "would you like to teardown the existing instance"
	[ "$teardown" = "n" ] && exit 0
	grab_yes_no "redeploy" "would you like to redeploy"
	[ "$redeploy" = "y" ] && export deployment_method="single"
elif [ ${login_exists:-1} -eq 0 ]; then
	# @note: login_exists so we are dealing with an existing distributed build
	echo "incomplete..."
	exit 0
fi

# ask for deployment options
grab "deployment_method" "what deployment method (single/distributed/none)?"

# if the image exists, ask if they wish to rebuild
if [ $(docker images | grep rathena | grep -c latest) -gt 0 ]; then
	grab_yes_no "rebuild" "do you want to rebuild the base image"
	[ "$rebuild" = "y" ] && export build="y"
else
	export build="y"
fi

# grab settings specific to a (re) build
if [ "$build" = "y" ]; then
	grab_yes_no "override_docker_build" "would you like to configure the image"
	if [ "$override_docker_build" = "y" ]; then
		grab "version" "what version of the repository should we checkout?"
		grab "prere" "will this be prere (yes/no)?"
		[[ "$prere" != "yes" || "$prere" != "no" ]] && unset prere
		grab "packetver" "what is the client packetver?"
	fi
	export version="${version:-master}"
	export prere="${prere:-no}"
	export packetver="${packetver:-20151029}"
fi

# ask questions related to each deployment method
if [ "$deployment_method" = "single" ]; then
	echo "Dangajits"
	# @todo: ask if they wish to change any credentials
	# grab_yes_no "expose_mysql" "would you like to expose mysql"
	# @todo: prepare an array for ports and sake only when conflicts arise
elif [ "$deployment_method" = "distributed" ]; then
	echo "incomplete..."
	exit 0
elif [ "$deployment_method" = "none" ]; then
	exit 0
fi


##
# begin handling activities
##

# cleanup single running container and base image
[ "${teardown:-n}" = "y" ] && docker stop $(docker ps -qaf "name=single-target") && docker rm $(docker ps -qaf "name=single-target")
[ "${rebuild:-n}" = "y" ] && docker rmi "rathena:latest"

# build default image
[ "$build" = "y" ] && docker build --build-arg "version=$version" --build-arg "prere=$prere" --build-arg "packetver=$packetver" --force-rm=true --no-cache=true -t "rathena:latest" .

# deployment process
if [ "$deployment_method" = "single" ]; then
	# @todo: switch to `docker run` so we can configure prior to launching rathena
	# @todo: create port map flag as a string, conditionally include mysql (may require eval or redundancy)
	# @todo: launch mysql
	# @todo: apply credential changes
	# @todo: launch rathena server software

	# @note: temporary solution is simple docker create leveraging the CMD from the Dockerfile to automate startup, and force mapping all services
	export cid=$(docker create --name="single-target" -ti -p "3306:3306" -p "5121:5121" -p "6121:6121" -p "6900:6900" rathena)
	docker start $cid
elif [ "$deployment_method" = "distributed" ]; then
	echo "incomplete..."
	exit 0
fi

# final safe exit code
exit 0
