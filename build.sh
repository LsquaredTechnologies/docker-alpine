#!/bin/bash

shopt -s globstar

build() {
	declare options_files="${*:-versions/**/options}"

	[[ "$BUILDER_IMAGE" ]] || {
		BUILDER_IMAGE="alpine-builder"
		echo ["DEBUG] ===== Building $BUILDER_IMAGE ====="
		docker build -t "$BUILDER_IMAGE" builder
	}

	for file in $options_files; do
		source "$file"
		local version_dir
		version_dir="$(dirname "$file")"
		: "${TAGS:?}" "${BUILD_OPTIONS:?}" "${RELEASE:?}"

		echo
		echo "[DEBUG] ===== Building $version_dir ====="
		docker run --rm $BUILDER_IMAGE ${BUILD_OPTIONS[@]} > $version_dir/rootfs.tar.xz
		
		# Build + tag images
		for tag in "${TAGS[@]}"; do
			echo "[DEBUG] ==== Building $tag ====="
			docker build -t "$tag" "$version_dir"
		done
	done

	# Clean up
	docker rmi "$BUILDER_IMAGE"
}

push() {
	declare options_files="${*:-versions/**/options}"
	for file in $options_files; do
		source "$file"
		for tag in "${TAGS[@]}"; do
			if docker history "$tag" &> /dev/null; then
				[[ "$PUSH_IMAGE" ]] && docker push "$tag"
			fi
		done
		exit 0
	done
}

main() {
	set -eo pipefail; [[ "$TRACE" ]] && set -x
	declare cmd="$1"
	case "$cmd" in
	    push)	shift;	push "$@";;
		*)		build "$@";;
	esac
}

main "$@"