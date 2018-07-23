# GPG
A Swift / SQLite / IDML based Price Grid Generator. This project uses FMDB by FlyingMeat. https://ccgus.github.io/fmdb/

23-Jul-18: Repo was de-synced and broken, this had to be removed from GitHub and refreshed, hence the name change.

What's New?
Added interface control for switching price grid formats,
Removed the multi-select button; I won't have time to implement this before I leave. (might do it later anyways).

Refactored GRJ IDML generation into it's own class,
Created a new class to handle RD IDML generation.

Bugs:
Fixed a bug that would cause the app to crash when selecting an RD layout grid option.

Known issues:
Selecting an RD layout option will result in a malformed price grid, 
Selecting an RD layout option will result in reduced optionals in the interface but these are not disabled.

