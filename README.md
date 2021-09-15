<div align="center">

# asdf-ccache [![Build](https://github.com/asdf-community/asdf-ccache/actions/workflows/build.yml/badge.svg)](https://github.com/asdf-community/asdf-ccache/actions/workflows/build.yml) [![Lint](https://github.com/asdf-community/asdf-ccache/actions/workflows/lint.yml/badge.svg)](https://github.com/asdf-community/asdf-ccache/actions/workflows/lint.yml)


[ccache](https://ccache.dev/documentation.html) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

### Build history

[![Build history](https://buildstats.info/github/chart/asdf-community/asdf-ccache?branch=master)](https://github.com/asdf-community/asdf-ccache/actions)

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`: generic POSIX utilities.
- A C/C++ compiler
- CMake (when installing ccache version 4 or newer)
- GNU make

# Install

Plugin:

```shell
asdf plugin add ccache
# or
asdf plugin add ccache https://github.com/asdf-community/asdf-ccache.git
```

ccache:

```shell
# Show all installable versions
asdf list-all ccache

# Install specific version
asdf install ccache latest

# Set a version globally (on your ~/.tool-versions file)
asdf global ccache latest

# Now ccache commands are available
ccache --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/asdf-community/asdf-ccache/graphs/contributors)!

# License

See [LICENSE](LICENSE)
