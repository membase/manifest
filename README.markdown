# Building With Repo

## Ensure You Have the Dependencies

### Mac OS X:

Using [homebrew][homebrew] and the ruby that ships with a recent OS X,
you can easily install the dependencies using the following commands:

    sudo easy_install -U pyrex
    brew install bzr --system
    brew install libevent

Optionally, you can install repo from homebrew as well:

    brew install repo

### Debian/Ubuntu:

Here's what I did on clean Debian stable (squeeze) installation (under root):

    aptitude install -y --without-recommends build-essential automake libtool pkg-config check libssl-dev sqlite3 libevent-dev libglib2.0-dev libcurl4-dev erlang-nox curl erlang-dev erlang-src ruby libmozjs-dev libicu-dev
    aptitude install -y python-minimal
    aptitude install -y --without-recommends git-core

Note that Debian squeeze ships Erlang R14A, yet Ubuntu 10.4, 10.10
(and 11.4 likely will) ship R13B03. As of this writing membase works
fine on R13, however this will change soon. To install R14 on Ubuntu I
recommend grabbing R14B source package from Debian Unstable (at the
time of writing it's still in Experimental) and dpkg-buildpackage'ing
it as usual.

This includes couchdb dependencies so you can pass
DONT_BUILD_COUCH_DEPS=1 to make.

## Get Repo

(if you didn't install from homebrew, or aren't running on Mac OS X)

    $ curl http://android.git.kernel.org/repo > ~/bin/repo
    $ chmod a+x ~/bin/repo

## Clone the Manifest

    $ mkdir membase
    $ cd membase
    $ repo init -u git://github.com/membase/manifest.git
    $ repo sync

## Build

    $ make

[homebrew]: https://github.com/mxcl/homebrew
