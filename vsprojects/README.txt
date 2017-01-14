Visual Studio 2015 project files generated from kBuild log of
successful VirtualBox OSE 5.1.12 build. All 185 of them!

Notes:

These aren't for actually building VirtualBox, they're just
for more easily working with the source code.

They only work with the directory structure created by
VirtualBox-EzBuild.

BUILDVBOX.bat must be run first so that all the source
files will be in the correct location.

What's implemented:

Exact includes for each project, preprocessor defines,
compiler options, and linker options.

What's not:

Custom build steps which include renaming some source files,
custom processing of some source files, compiling .ASM files,
and probably other steps I haven't noticed yet.

Project dependencies

Separate options for individual source files within a project.
Not sure if that even happens, but currently all command-line
options are parsed individually, with any option used on one
source file applying to *all* sources (or libs) in that project.

Enjoy!