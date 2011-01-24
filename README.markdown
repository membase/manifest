# Building With Repo

## Ensure You Have the Dependencies

### OS X:

Using [homebrew][homebrew] and the ruby that ships with a recent OS X,
you can easily install the dependencies using the following commands:

    sudo brew install libevent bzr
    sudo gem install --remote sprockets

## Get Repo

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
