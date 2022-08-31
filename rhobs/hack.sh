#!/usr/bin/env bash
set -e -u -o pipefail

declare SCRIPT_PATH
SCRIPT_PATH="$(readlink -f "$0")"

declare PROJECT_ROOT
PROJECT_ROOT="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"


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

  make generate
  return $?
}

main "$@"
