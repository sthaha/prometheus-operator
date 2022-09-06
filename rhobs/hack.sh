#!/usr/bin/env bash
set -e -u -o pipefail

declare SCRIPT_PATH
SCRIPT_PATH="$(readlink -f "$0")"

declare PROJECT_ROOT
PROJECT_ROOT="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"


bumpup_version(){
  # get all tags with
  local version=$(head -n1 VERSION)
  # remove any trailing rhobs
  local upstream_version=${version//-rhobs*}
  echo "found upstream version: $upstream_version"

  # find git tags with
  local patch
  # git tag | grep "^v$upstream_version-rhobs" | wc -l
  # NOTE: grep || true prevents grep from setting non-zero exit code
  # if there are no -rhobs tag

  patch=$( git tag | { grep "^v$upstream_version-rhobs" || true; } | wc -l )
  (( patch+=1 ))

  rhobs_version="$upstream_version-rhobs$patch"

  echo "Updating version to $rhobs_version"
  echo $rhobs_version > VERSION
}

publish_images() {
  local version=$1; shift

  local image_operator="quay.io/sthaha/rhobs-prometheus-operator"
  local image_webhook="quay.io/sthaha/rhobs-po-admission-webhook"
  local tag="v$version"

  make image IMAGE_OPERATOR="$image_operator" \
    IMAGE_WEBHOOK="$image_webhook" \
    TAG="$tag"

  docker push "$image_operator:$tag"
  docker push "$image_webhook:$tag"
}


main() {
  # all files are relative to the root of the project
  cd "$PROJECT_ROOT"

  rm -f example/prometheus-operator-crd-full/monitoring.coreos.com*
  rm -f example/prometheus-operator-crd/monitoring.coreos.com*

  # change the kubebuilder group to monitoring.rhobs
  # change the category  to rhobs-prometheus-operator
  # remove all shortnames

  find \( -path "./.git" -o -path "./rhobs" \) -prune -o -type f -exec \
    sed -i  \
      -e 's|monitoring.coreos.com|monitoring.rhobs|g'   \
      -e 's|+kubebuilder:resource:categories="prometheus-operator".*|+kubebuilder:resource:categories="rhobs-prometheus-operator"|g' \
  {} \;

  bumpup_version

  local version
  version=$(head -n1 VERSION)


  make generate
  publish_images "$version"

  return $?

}

main "$@"

##
