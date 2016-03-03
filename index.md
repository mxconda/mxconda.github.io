---
layout: default
---

### complementary software collection for macromolecular crystallography

## Focus

- the latest versions of rapidly developed programs - for quick feedback loop, and
- open-source programs that otherwise may be hard to install

## MXconda is

- built on top of [Anaconda Python](https://www.continuum.io/anaconda)
  and powered by its package manager
  ([conda](http://conda.pydata.org/docs/))
- for Linux and OS X, planned also for Windows
- easy to install, even easier to remove: contained in a single directory
- quick to update: let us use coot as an example - `mx update coot`
  will download only a 17MB package - coot itself, not all dependencies (100MB)
- quick to downgrade: you may easily go back to the last release
  (`mx install coot==0.8.2`) or to older development snapshot
  (`mx search coot` shows all available versions)
- designed to avoid conflicts when the same programs are installed
  also outside of mxconda
- developer friendly and CI-server friendly (details [below](#libraries))

## Initial set of packages

 - coot (and also raster3d, probe and reduce)
 - pymol (open-source version)
 - *[in testing]* cctbx (big bundle that includes DIALS and Molprobity)
 - *[considered]* [mifit](https://github.com/mifit/mifit)
 - *[considered]* [d-star-trek](https://github.com/tlhrigaku/d-star-trek)
 - and all necessary dependencies
 - plus [all Anaconda packages](http://docs.continuum.io/anaconda/pkg-docs)
   available when you need them


## Installation

No need for sudo.
Download and run [get.sh](https://mxconda.github.io/git.sh),
or just:

    curl -fsS https://mxconda.github.io/get.sh | sh

The script asks you where to install mxconda and at the end
proposes to create a symlink in your PATH to a launcher script called `mx`.

Which brings us to...

## Usage

The `mx` script wraps all package operations (it just passes arguments to `conda`):

    mx install coot
    mx update coot
    mx update --all
    mx search coot
    mx install coot==0.8.2
    mx remove coot
    mx info coot
    mx clean --packages --tarballs

The same script is used to start programs:

    mx coot
    mx pymol my.pdb

and called without arguments, it starts bash subshell with all programs
in the PATH:

    mx

Alternatively, you could add `$HOME/mxconda/bin` to the PATH
in a startup file. Although we do not encourage it -
if the same programs are installed also outside of mxconda
it is easy to get confused which version is run.

## Background

Conda is a general-purpose package manager (with extra functionality
for Pythonic packages). In addition to the official set of packages
(Anaconda Python) users may create _channels_ with custom packages.
In principle the packages can be hosted anywhere, but since anaconda.org
conveniently offers free hosting, there is no reason not to use it.

Anaconda is particularly popular in scientific software circles.
Googling conda+crystallography or conda+synchrotron shows that conda
channels are already a recommended way of distributing software
in [some](http://www.chess.cornell.edu/software/anaconda/index.htm)
[facilities](https://nsls-ii.github.io/conda.html).
A nearby field of bioinformatics has a channel called
[Bioconda](https://bioconda.github.io/) maintained by 40+ people.

Technically, MXconda is realized as a conda channel and
if you already use Anaconda with Python 2.7, you could just
add the [mx](https://conda.anaconda.org/mx) channel to it.
But it may cause conflicts -- we replace some of the official
Anaconda packages. We use newer Boost and our Tcl/Tk on Mac is
compiled with different options (for Pymol).

Conda does not clean up old package versions automatically.
That is why reverting to older version of a package takes no time
(files are not even copied, only hardlinked).
But if the MXconda directory gets too big, do `mx clean -pt`.
`-p` removes unused (unpacked) packages, `-t` removes package tarballs.

Finally, for more complex installation scenarios one could take advantage of
[conda environments](http://conda.pydata.org/docs/using/envs.html),
but this is outside of the scope of this text, at least for now.

## Libraries

Packaged libraries include C/C++ headers. You may compile own programs
linking with libraries from MXconda, if you use the same C++ ABI:

- Linux packages are built with GCC 4.x. If you use GCC 5+ you need
  `-D_GLIBCXX_USE_CXX11_ABI=0` and possibly also `-std=c++98`.

- OS X packages are built with `-stdlib=libstdc++` for compatibility with 10.6.

It all works nicely on CI servers. For example, installing conda and
using it to install mmdb, libccp4 and clipper libraries takes
[15s on Travis](https://travis-ci.org/ccp4/dimple/builds/111474656#L130).


## thoughts?

email wojdyr@gmail.com

