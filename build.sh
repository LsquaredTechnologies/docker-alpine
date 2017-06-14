#!/bin/bash

build() {
	declare build_files="${*:-versions/**/options}"

	[[ "$BUILDER_IMAGE" ]] || {
		BUILDER_IMAGE="alpine-builder"
		echo ["DEBUG] ===== Building $BUILDER_IMAGE ====="
		docker build -t "$BUILDER_IMAGE" builder
	}

	for file in $build_files; do
		echo
		# shellcheck source=versions/alpine-3.2/options
		source "$file"
		local version_dir
		version_dir="$(dirname "$file")"
		: "${TAGS:?}" "${BUILD_OPTIONS:?}" "${RELEASE:?}"

		echo "[DEBUG] ===== Building $version_dir ====="
		docker run --rm $BUILDER_IMAGE ${BUILD_OPTIONS[@]} > $version_dir/rootfs.tar.xz
		
		for tag in "${TAGS[@]}"; do
			echo "[DEBUG] ==== Building $tag ====="
			docker build -t "$tag" "$version_dir"
		done
	done

	# Clean up
	docker rmi "$BUILDER_IMAGE"
}

main() {
	set -eo pipefail; [[ "$TRACE" ]] && set -x
	build "$@"
}

main "$@"