# Building With Repo

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
