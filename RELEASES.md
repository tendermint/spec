# Releases

The Tendermint specification follows [semantic versioning](https://semver.org/). Implementations of the Tendermint protocol are encouraged to either mirror versions or have some form of mapping for clear readibility of the state of the implementation. The `master` branch is used for active protocol development. Developers should be wary that the specifications are subject to change and should instead rely on the latest release. In the event of a security vulnerability, fixes may be backported to prior major releases but generally only the last major release is supported. The following documentation is provided to describe the release process.

## Major Releases

Before any major release, it is preferable to create release candidates (RC) for Tendermint implementations as well as applications to test out and validate. This is done using git tags which are built off major release branches i.e. `v0.35.x`.

Tags for RCs should follow the "standard" release naming conventions, with `-rcX` at the end (for example, `v0.35.0-rc0`) and incrementing from `0`.

If this is the first RC, then you'll need to create a new branch for the major release:

1. Start on `master`
2. Create and push the new branch: `git checkout -b v0.35.x && git push origin v0.35.x`

Now, to prepare the new RC:

1. Start from the major release branch (e.g. `v0.35.x`).
2. Prepare the changelog by renaming `unreleased` to the RC name and make sure all important changes are documented.
3. Open up a PR with these changes against the major release branch.
4. Once these changes have landed, be sure to pull them back down locally.
5. Create the new tag, specifying a name and a tag "message": `git tag -a v0.35.0-rc0 -m "Release Candidate v0.35.0-rc0"`.
6. Push the tag back up to the origin: `git push origin v0.35.0-rc0`.
7. Add the `unreleased` header and template to the `CHANGELOG` file for future changes on the major release branch.

Any future changes will need to be pushed to `master` and then backported to the respective major release branch. When the release candidates have stabilized, we can begin to tag the major release.

1. Start on the major release branch (e.g. `v0.35.x`).
2. Squash the changes from the changlog entries for each release candidate together into a single header with the major release name.
3. Open a PR with these changes against the major release branch.
4. Once the changes have been merged, create a tag with prepared release details: `git tag -a v0.35.0 -m "Release v0.35.0"`.
5. Push the tag: `git push origin v0.35.0`.
6. Update the `CHANGELOG` by addind a new `unreleased` section following the same template. Open a PR for this.
7. Port over the new changelog entry to `master` as well.

## Minor Releases

Specification changes can be backported to a major version if necessary. This can then be included in the next minor release. The minor release process usally requires no release candidates and is tagged off the relevant major release branch.

Follow the same process as with the major release but using the minor release tag (e.g. `v0.35.1`)
