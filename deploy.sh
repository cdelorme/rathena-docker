#!/bin/bash -eux

# exit if docker does not exist
if ! which docker; then echo "docker required..." && exit 1; fi

grab_yes_no()
{
	[[ "$(eval echo \${$1:-})" = "y" || "$(eval echo \${$1:-})" = "n" ]] && return 0
	export ${1}=""
	until [[ "$(eval echo \$$1)" = "y" || "$(eval echo \$$1)" = "n" ]]; do
		read -p "${2:-} (yn)? " ${1}
	done
	return 0
}

# if the image exists, ask if they wish to rebuild
[ $(docker images | grep rathena | grep -c latest) -gt 0 ] && grab_yes_no "rebuild" "do you want to rebuild the base image"
[ "${rebuild:-n}" = "y" ] && docker rmi "rathena:latest"

# rebuild image if it does not exist
[ $(docker images | grep rathena | grep -c latest) -gt 0 ] || docker build --force-rm=true --no-cache=true -t "rathena:latest" .
