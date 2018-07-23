# GPG
A Swift / SQLite / IDML based Price Grid Generator. This project uses FMDB by FlyingMeat. https://ccgus.github.io/fmdb/

23-Jul-2018

What's new?
Updated the core module for producing RD Grids.
Refactored the code that determines the type of grid that is used. this is now decide much earlier.
Added several methods for producing RD Branded IDML code.

Bugs Fixed:
Selecting an RD layout will result in a malformed price grid. - This now only occurs if the total table rows are greater than 15. Tables over 15 rows are to be addressed shortly with a separate layout for the grid.
Selecting an RD layout option will result in reduced optionals in the interface but these are not disabled. - this has now been fixed. all non required controls on the interface adjust correctly between RD/GRJ.

Known Issues:
Colouring on the RD gris offsets by a factor of one when running across two years.
A 'range out of bounds' exception occurs when attempting to use an array with only one element. (this one should be an easy fix, the note is to remind me)
Three-column RD grids are produced in a malformed output.


-----------


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

