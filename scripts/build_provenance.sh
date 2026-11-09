#!/bin/bash
# Build the Provenance linux release zip from a checkout already mounted as
# the working directory. The caller runs this inside ubuntu:20.04 so the
# binary links glibc 2.31 and can start in the Debian Bullseye test image.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Ledger support is compiled in by default and the Makefile stops when gcc is
# missing. The compression libraries are the same set the Provenance linux
# release job installs.
apt-get update
apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  curl \
  git \
  libbz2-dev \
  libgflags-dev \
  liblz4-dev \
  libsnappy-dev \
  libzstd-dev \
  make \
  zip \
  zlib1g-dev

# The checkout is mounted from the runner, so git would otherwise refuse to
# read it once this image ships a git that checks directory ownership.
git config --global --add safe.directory "$(pwd)"

# Install the toolchain this ref declares. validate-go-version rejects any
# other minor, and that check belongs to the checked-out Makefile.
go_version="$(awk '/^go / { print $2; exit }' go.mod)"
if [[ -z "${go_version}" ]]; then
  echo "go.mod does not declare a Go version" >&2
  exit 1
fi

# A two-part directive such as "go 1.21" is not a tarball name. Use the newest
# published patch for that minor. Escape dots so the version is matched literally.
if [[ ! "${go_version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  go_version_re="${go_version//./\\.}"
  go_version="$(
    curl -fsSL 'https://go.dev/dl/?mode=json' \
      | grep -oE "\"go${go_version_re}\\.[0-9]+\"" \
      | tr -d '"' \
      | sed 's/^go//' \
      | sort -t. -k1,1n -k2,2n -k3,3n \
      | tail -1
  )"
fi

if [[ -z "${go_version}" ]]; then
  echo "could not resolve a Go toolchain from go.mod" >&2
  exit 1
fi

echo "Installing Go ${go_version}"
curl -fsSL "https://go.dev/dl/go${go_version}.linux-amd64.tar.gz" -o /tmp/go.tgz
rm -rf /usr/local/go
tar -C /usr/local -xzf /tmp/go.tgz
export PATH="/usr/local/go/bin:${PATH}"

# Stay on the toolchain just installed. A newer GOTOOLCHAIN would download
# another Go and could change the version the Makefile accepts.
export GOTOOLCHAIN=local

# Leave VERSION unset. The Makefile uses the tag on HEAD, or <branch>-<sha>
# with slashes turned into dashes, so the zip name stays a single path segment.
make build-release-zip

# The container runs as root. Give the tree back to the runner so it can copy
# the zip out and delete the checkout.
if [[ -n "${HOST_UID:-}" && -n "${HOST_GID:-}" ]]; then
  chown -R "${HOST_UID}:${HOST_GID}" "$(pwd)"
fi
