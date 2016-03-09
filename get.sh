#!/bin/sh

# This script installs the MXconda by downloading, install and configuring
# Miniconda, and then using it to install package 'mx'.

do_install() {

set -e
set -u
mini=

die() {
  echo "$@" >&2
  [ -n "$mini" ] && rm -f "$mini"
  exit 1
}

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

if command_exists mx; then
  echo 'Command "mx" already exists on your system.'
  echo 'If it is not from MXconda - please drop me a line: wojdyr@gmail.com'
  die 'Not sure what to do. Exiting.'
fi

download=''
if command_exists curl; then
  download='curl -L'
elif command_exists wget; then
  download='wget -O-'
elif command_exists busybox && busybox --list-modules | grep -q wget; then
  download='busybox wget -qO-'
else
  die "ERROR: neither curl nor wget is installed?"
fi

case "$(uname -s).$(uname -m)" in
  Linux.x86_64) fn=Miniconda-latest-Linux-x86_64.sh;;
  Linux.i?86) fn=Miniconda-latest-Linux-x86.sh;;
  Darwin.*) fn=Miniconda-latest-MacOSX-x86_64.sh;;
  *) die "Sorry, only Linux (x86 and x86_64) and OS X 10.6+ is supported.";;
esac

# determine installation prefix
prefix="$HOME/mxconda"
echo -n "
MXconda (based on Miniconda2) will now be installed into this location:
$prefix

 - Press ENTER to confirm the location
 - Press Ctrl-C to abort the installation
 - Or specify a different location below (no spaces in the path)

>>> "
read user_prefix
[ -n "$user_prefix" ] && prefix="$user_prefix"

# do the same checks as Miniconda - better to fail early
[ -e "$prefix" ] && die "ERROR: File or directory already exists: $prefix"
mkdir -p "$prefix" || die "ERROR: Could not create directory: $prefix"
# it needs to be absolute when creating symlink
prefix="$(cd "$prefix" && pwd)"
rmdir "$prefix" || die "Failed to create and remove directory - as a test."

# download Miniconda
mini="$(mktemp ${TMPDIR:-/tmp}/Miniconda2-XXXXXX.sh)"
url="https://repo.continuum.io/miniconda/$fn"
echo "
Downloading Miniconda from
$url
Do not continue unless you agree to Anaconda license agreement:
http://docs.continuum.io/anaconda/eula
" >&2
$download $url >>"$mini" || die "Download failed."

# install Miniconda
echo "Installing $url ..." >&2
bash "$mini" -b -p "$prefix" || die "Installation failed."
$prefix/bin/conda config --add channels https://conda.anaconda.org/mx
echo "Installing initial packages..." >&2
rm -f "$mini" && mini=

# nomkl is installed to avoid downloading 100+MB Intel MKL package
echo "Installing initial packages..." >&2
$prefix/bin/conda install nomkl mx -y || die "Failed."

# symlink
if [ -w "$HOME/bin" ]; then
  bindir="$HOME/bin"
elif [ -w "$HOME/.local/bin" ]; then
  bindir="$HOME/.local/bin"
elif [ -w /usr/local/bin ]; then
  bindir="/usr/local/bin"
elif [ -w /usr/bin ]; then
  bindir="/usr/bin"
else
  bindir=
fi

# check that $bindir is in $PATH
case ":$PATH:" in
    *:$bindir:*) ;;
    *) bindir= ;;
esac

symlink_info="
You have everything installed, but to make the mx easily available\\033[1m
you need to symlink it (not copy!) to one of directories in your PATH.\\033[0m
The command for this is:
ln -s $prefix/bin/mx /your/favourite/bin/"

if [ -n "$bindir" ]; then
  echo -n "
 The last step: create symlink in a directory in your PATH pointing to:
 $prefix/bin/mx
 - Press ENTER to create symbolic link in:
   $bindir
 - Press Ctrl-C to finish without symlink
 - Or specify a different directory below

>>> "
  read user_bin
  [ -n "$user_bin" ] && bindir="$user_bin"
  echo "ln -s $prefix/bin/mx $bindir/" >&2
  ln -s $prefix/bin/mx $bindir/ || echo -e "$symlink_info"
else
  echo -e "$symlink_info"
fi

echo "
Thank you for trying this experimental version of MXconda.
Feedback is welcome. We are genuinely interested what you think." >&2
}

do_install
