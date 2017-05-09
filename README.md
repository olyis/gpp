# gpp
Utilities to wrap and extend git
---
'gpp' means 'Git Plus Plus'! - a cautiously grandiose gesture pointing to the central idea of this project: to attempt to marginally increase the utility of git on the command line. It's also my way of exploring how git works and increasing my understanding of its internal workings.

gpp is fully compatible with git.

Usage
---
In this current draft implementation, gpp is a single powershell script which you must dot-source like so:

    PS > . .\path-to-script\gpp.ps1

After this, you get fun features like branch name autocomplete

    > Checkout-Branch -Name _
                            master
                            dev/my-feature-branch
                            ...

You get even better support if you use the powershell ISE.

At some stage gpp could be refactored into a collection of cmdlets which can then be installed just once, or perhaps its own command line utility so it's better available to non-windows users.

Commands available
---

    Get-GitFolder

Parameters:

- Throw (Flag): signal whether or not to throw if no git folder found.

Output:

Zero or one [System.IO.FileSystemInfo] objects representing the .git folder of the nearest ancestor of the current location which has one (i.e. the current git repository).

------

    Get-Branch

Parameters:

- Remote [Flag]: switch from looking at local branches to remote branches.

Output:

Zero or more (usually one or more!) objects with shape `{Name: string; Target: string}` representing the name and current commit reference of either the local or remote branches known to the repository.

e.g.

    {Name: 'master'; Target: '43b32...'}
    {Name: 'dev/feature'; Target: 'ef3d56...'}

This output is subject to change.

------

    Checkout-Branch

Parameters:

- Remote [Flag]: switch from looking at local branches to remote branches.
- Name [String]: name of the branch to checkout. This parameter has __autocomplete__.

Output:

None

Behaviour:

Calls through to `git checkout` on the chosen branch.

This may be supplemented with powershell standard flag `-WhatIf`.
