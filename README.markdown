# Building With Repo

## Ensure You Have the Dependencies

### Mac OS X:

Using [homebrew][homebrew] and the ruby that ships with a recent OS X,
you can easily install the dependencies using the following commands:

    sudo easy_install -U pyrex
    brew install bazaar --system
    brew install libevent
    brew install gnupg
    brew install v8
    brew install snappy
    brew install erlang

Optionally, you can install repo from homebrew as well:

    brew install repo

If you have a recent version of Xcode (4.3+), it no longer lives in the `/Developer` directory. This
will cause one of the subcomponents (Sigar) to fail to build. For the time being the workaround is to create
a symbolic link from the old (expected) header files directory, to the new place Xcode likes to keep
it's headers. Do it like this:

    sudo ln -s  /Applications/Xcode.app/Contents/Developer /Developer

### Debian/Ubuntu:

The following works for a clean Debian stable (squeeze) installation (under root):

    aptitude install -y --without-recommends build-essential automake libtool pkg-config check libssl-dev sqlite3 libevent-dev libglib2.0-dev libcurl4-openssl-dev erlang-nox curl erlang-dev erlang-src ruby libmozjs-dev libicu-dev
    aptitude install -y python-minimal
    aptitude install -y --without-recommends git-core

Note that Debian squeeze ships Erlang R14A, yet Ubuntu 10.4, 10.10 and
even 11.4 ship R13B03. As of this writing, couchbase requires R14B.

To install R14 on Ubuntu, you can grab R14B source package from Debian
Unstable and dpkg-buildpackage'ing it as usual.

Another (any likely preferred) option is to get R14B02 from PPA:
https://launchpad.net/~scattino/+archive/ppa

In order to link with xulrunner on ubuntu (which lacks libmozjs-dev)
you need the following:

    aptitude install -y xulrunner-dev

and then you need to pass extra options to make like this:

    make couchdb_EXTRA_OPTIONS='--with-js-include=/usr/include/xulrunner-1.9.2.16 --with-js-lib=/usr/lib/xulrunner-devel-1.9.2.16/sdk/lib/'

The path seems to vary with version. 'dpkg -l xulrunner-dev' will help you
find the right path.

## Get Repo

(if you didn't install from homebrew, or aren't running on Mac OS X)

Get the latest version from [the google project page](http://code.google.com/p/git-repo/downloads/list).

## Clone the Manifest

For `<branch_name>` below, you probably want to use `branch-2.0.xml` unless you are working on a 
maintenance or experimental branch.

    $ mkdir couchbase
    $ cd couchbase
    $ repo init -u git://github.com/membase/manifest.git -m <branch_name>
    $ repo sync

## Build

    $ make

[homebrew]: https://github.com/mxcl/homebrew
