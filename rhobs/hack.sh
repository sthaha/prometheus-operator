#!/usr/bin/env bash
set -e -u -o pipefail

declare SCRIPT_PATH
SCRIPT_PATH="$(readlink -f "$0")"

declare PROJECT_ROOT
PROJECT_ROOT="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"


main() {
  # all files are relative to the root of the project
  cd "$PROJECT_ROOT"

  # change the kubebuilder group to
  # find . -path ./.git -prune  -path ./rhobs -type f \
  find \( -path "./.git" -o -path "./rhobs" \) -prune -o -type f \
    -exec  sed -i  \
      -e 's|monitoring.coreos.com|monitoring.rhobs|g'  {} \;

  rm -f example/prometheus-operator-crd-full/monitoring.coreos.com*
  rm -f example/prometheus-operator-crd/monitoring.coreos.com*

  return $?
}

main "$@"
