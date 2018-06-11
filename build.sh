#!/usr/bin/env sh

shopt -s globstar

image_pull() {
	local pull_url file dir
  pull_url="$1"
	dir="$2"
	file="${pull_url##*/}"

	curl -fSsL "$pull_url" > "$dir/rootfs.tar.gz"
}

image_build() {
	local build_options dir
	build_options="$1"
	dir="$2"

	[[ "$BUILDER_IMAGE" ]] || {
		BUILDER_IMAGE="alpine-builder"
		docker build -t "$BUILDER_IMAGE" builder
	}

	docker run -e "TRACE=$TRACE" --rm "$BUILDER_IMAGE" "${BUILD_OPTIONS[@]}" \
		> "$version_dir/rootfs.tar.xz"
}

build() {
	declare options_files="${*:-versions/**/options}"

	for file in $options_files; do
		( # shellcheck source=versions/gliderlabs-3.2/options
		source "$file"
		local version_dir
		version_dir="${file%/*}"
		: "${TAGS:?}"

		[[ "$PULL_URL" ]] && image_pull "$PULL_URL" "$version_dir"
		[[ "$BUILD_OPTIONS" ]] && image_build "${BUILD_OPTIONS[@]}" "$version_dir"

		# Build + tag images
		for tag in "${TAGS[@]}"; do
			docker build -t "$tag" "$version_dir"

			if [[ "$CIRCLE_BUILD_NUM" ]]; then
				{
					mkdir -p images \
					&& docker tag -f "$tag" "${tag}-${CIRCLE_BUILD_NUM}" \
					&& docker save "${tag}-${CIRCLE_BUILD_NUM}" \
						| xz -9e > "images/${tag//\//_}-${CIRCLE_BUILD_NUM}.tar.xz" \
					&& docker rmi "${tag}-${CIRCLE_BUILD_NUM}"
				} || true
			fi
		done )

	done
}

commit() {
	declare options_files="${*:-versions/**/options}"
	local current_branch
	current_branch=$(git rev-parse --abbrev-ref HEAD)
	: "${current_branch:?}"

	for file in $options_files; do
		local release version_dir
		version_dir="${file%/*}"
		release="${version_dir##versions/}"

		: "${release:?}" "${version_dir:?}"

		git checkout -B "rootfs/$release" "$current_branch"
		git add -f -- "$version_dir/rootfs.tar.*"
		git commit -m "release image version $release"
	done

	[[ "$NO_PUSH" ]] || git push -f origin 'refs/heads/rootfs/*'
	git checkout "$current_branch"
}

push() {
	[[ "$NO_PUSH" ]] && return 0

	declare options_files="${*:-versions/**/options}"
	for file in $options_files; do
		( #shellcheck source=versions/gliderlabs-3.2/options
		source "$file"
		for tag in "${TAGS[@]}"; do
			if docker history "$tag" &> /dev/null; then
				[[ "$PUSH_IMAGE" ]] && docker push "$tag"
			fi
		done
		exit 0 )
	done
}

main() {
	set -eo pipefail; [[ "$TRACE" ]] && set -x
	declare cmd="$1"
	case "$cmd" in
		commit)	shift;	commit "$@";;
		push)	shift;	push "$@";;
		*)		build "$@";;
	esac
}

main "$@"