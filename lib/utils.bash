#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/ccache/ccache"
TOOL_NAME="ccache"
TOOL_TEST="ccache --version"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if ccache is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
  # Change this function if ccache has other means of determining installable versions.
  list_github_tags
}

download_release() {
  local version filename url
  version="$1"
  filename="$2"
  url="$GH_REPO/releases/download/v${version}/${TOOL_NAME}-${version}.tar.gz"
  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="$3"
  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  (
    mkdir -p "$install_path"
    echo "∗ Configuring..."
    local source_dir="$ASDF_DOWNLOAD_PATH"
    local build_dir="${source_dir}/build"

    if [[ "$version" =~ ^[0-3]\. ]]; then
      cd "$source_dir"
      ./configure --prefix="$install_path" >/dev/null || fail "Could not configure"
    else
      cmake -DCMAKE_INSTALL_PREFIX="$install_path" \
        -DCMAKE_BUILD_TYPE=Release \
        -DZSTD_FROM_INTERNET=yes \
        -S "$source_dir" -B "$build_dir" >/dev/null || fail "Could not configure CMake"
    fi

    echo "∗ Compiling..."
    if [[ "$version" =~ ^[0-3]\. ]]; then
      make --jobs="$ASDF_CONCURRENCY" &>log.make || fail "Could not compile"
    else
      cmake --build "$build_dir" --parallel "$ASDF_CONCURRENCY" &>log.make || fail "Could not compile"
    fi

    echo "∗ Installing..."
    if [[ "$version" =~ ^[0-3]\. ]]; then
      make install >/dev/null || fail "Could not install"
    else
      cmake --install "$build_dir" >/dev/null || fail "Could not install"
    fi

    local tool_cmd
    tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
    test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/bin/$tool_cmd to be executable."

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error ocurred while installing $TOOL_NAME $version."
  )
}
