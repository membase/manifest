# Which Manifest Do I Use?

## Released Versions of Couchbase Server

When we make a release, we take the manifest emitted from the builder
and store it in the released/ directory.  This manifest only has exact
commit SHAs, so that it explicitly describes which revision was used,
in both Couchbase and external repositories.

It also gives the revision of the "voltron" repo used in the build.
Voltron contains build instructions --- like RPM spec files -- that
are used at the top level before the manifest is used to fetch files
from the source repos.  Because the voltron repo is private, it is
marked with the "notdefault" group so "repo" will not attempt to
download it unless the command "repo init -g all" is specified.

To replicate a released build use a manifest from the released/
directory.

## Versions of Couchbase Server Prior to Release

If you want to build the development branch you should use
"branch-master.xml".

While preparing for a product release, based on the version of Couchbase
server being handled, the manifest to use for the build can be in one
of several locations:

- For spock and later versions, in the couchbase-server/ subdirectory
- For watson and previous versions, in the top-level directory
  * This includes the branch-master manifest
- For branch manifests, in the couchbase-server/<release>/ subdirectories
  * The exceptions to this are sherlock 4.0.0 and 4.1.0

You will not need to use any of these manifests unless you are
contributing changes towards a Couchbase release.

## Couchbase Experimental Builds

The toy/ directory is used by Couchbase developers for experimental builds,
and so are probably not of interest to anyone not familiar with the context
of the experiment.
