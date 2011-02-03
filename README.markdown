# Building With Repo

## Ensure You Have the Dependencies

### Mac OS X:

Using [homebrew][homebrew] and the ruby that ships with a recent OS X,
you can easily install the dependencies using the following commands:

    sudo easy_install -U pyrex
    brew install bzr --system
    brew install libevent
    sudo gem install --remote sprockets

Optionally, you can install repo from homebrew as well:

    brew install repo

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
