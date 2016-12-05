#!/bin/bash -eu

# exit if docker does not exist
if ! which docker; then echo "docker required..." && exit 1; fi

# define helper functions for grabbing inputs
grab()
{
	[ -n "$(eval echo \${$1:-})" ] && return 0
	export ${1}=""
	read -t 30 -p "${2:-input}: " ${1}
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

# sanely ask about build, deployment, and configuration
if [ $(docker images -q rathena:latest | wc -l) -gt 0 ]; then
	grab_yes_no "build" "do you want to rebuild the base image"
fi
export build="${build:-y}"
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
	export packetver="${packetver:-20151104}"
fi
if [ $(docker ps -qaf "name=rathena" | wc -l) -gt 0 ]; then
	grab_yes_no "teardown" "would you like to teardown the existing instance"
	[ "$teardown" = "n" ] && exit 0
	grab_yes_no "deploy" "would you like to redeploy"
fi
grab_yes_no "deploy" "would you like to deploy"

# cleanup, build, and deploy
[ "${teardown:-n}" = "y" ] && docker stop $(docker ps -qaf "name=rathena") && docker rm $(docker ps -qaf "name=rathena")
[ "$build" = "y" ] && ([ $(docker images -q rathena:latest | wc -l) -eq 0 ] || docker rmi "rathena:latest") && docker build --build-arg "version=$version" --build-arg "prere=$prere" --build-arg "packetver=$packetver" --force-rm=true --no-cache=true -t "rathena:latest" .
[ "$deploy" = "y" ] && export cid=$(docker create --name="rathena" -p "3306:3306" -p "5121:5121" -p "6121:6121" -p "6900:6900" -ti rathena) && docker start $cid
