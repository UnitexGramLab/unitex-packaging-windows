## Unitex/GramLab Setup Installer for Windows

> [Unitex/GramLab][unitex] is an open source, cross-platform, multilingual, lexicon- and grammar-based corpus processing suite.

This NSIS script is used to create the [Unitex/GramLab][unitex] setup installers
for Windows on POSIX compliant systems. NSIS (Nullsoft Scriptable
Install System) is a scripting tool to create Windows installers.
Installers are generated by using the `makensis` program to compile a
NSIS script (.nsi) into an executable. NSIS is released under an open
source license and is completely free for any use. For more details,
please visit the [nsis website][nsis].

### Script dependencies
- **NSIS** distribution (version >= 3.0). Type `makensis -VERSION` to test your version.  
  If you need an update version, please visit [nsis]
- **GNU awk** (version >= 3.0) Type `awk --version` to test your version.  
  If you need an update version, please visit http://www.gnu.org/software/gawk/

### Script compilation
Usage:  
 `makensis -DVER_MAJOR=# -DVER_MINOR=# -DVER_REVISION=# [OPTIONS] unitex.nsi`

For a full list of compiler flags supported by this program, just type
`makensis unitex.nsi` [return] at the command line. For a full list of
parameters and further information about the makensis command, type
`makensis` [return]. 

#### Example

> Before beginning, please remember that this program only compiles on
> POSIX compliant systems (i.e. not on Windows). This is mainly due to the use
> of the `!system` command thats runs with /bin/sh. There aren't any plans for
> a Windows support at the moment.

1. Download the [bundle zip](http://www-igm.univ-mlv.fr/~unitex/zips/Unitex3.1beta.zip)
   containing the Unitex/GramLab distribution from the [Unitex/GramLab][unitex] homepage.
2. Unzip all files in a folder at one time.
3. Take notice of the main folder name:  
   `Unitex${VER_MAJOR}.${VER_MINOR}${VER_SUFFIX}`, e.g.  
   **Unitex3.0**      `VER_MAJOR=3 VER_MINOR=0 VER_SUFFIX=""`  
   **Unitex3.1beta**  `VER_MAJOR=3 VER_MINOR=1 VER_SUFFIX="beta"`
4. Take notice of the parent folder name, i.e. the directory where the  
   main Unitex directory is placed. This directory will be your `${INPUT_BASEDIR}` path.
5. Create the final setup installer typing:  
   `makensis -DANONYMOUS_BUILD  -DINPUT_BASEDIR=path -DVER_MAJOR=number -DVER_MINOR=number -DVER_SUFFIX=suffix unitex.nsi`  
   For example:  
   `makensis -DANONYMOUS_BUILD  -DINPUT_BASEDIR=. -DVER_MAJOR=3 -DVER_MINOR=1 -DVER_SUFFIX=beta unitex.nsi`  
   This will create an executable named: `Unitex-GramLab-3.1beta_anonymous_win32-setup.exe`

Non-anonymous builds are further documented [here](unitex.nsi)

### Setup installer command line parameters

The produced Unitex/GramLab Windows setup installer accepts several optional
command line parameters. Some common options are:

| Option                     | Description                                           |
| -------------------------- | ----------------------------------------------------- |
| `/AllUsers`                  | Set default to a per-machine installation             |
| `/CurrentUser`               | Set default to a per-user installation.               |
| `/D C:\path\without quotes\` | Sets the default installation directory. It mustbe the last parameter and must not contain any quotes. Only absolute paths are supported|
| `/NCRC`                      | The installer will not perform a Cyclic Redundancy Check (CRC) on itself before allowing an install     |
| `/S`                         | Runs the installer or the uninstaller silently        |

### Setup installer features

 - [x] User selection of Unitex/GramLab installation components (Core Components,  
   Visual IDEs, Linguistic Resources, Source Code, User Manual, Start Menu  
   and Desktop Shortcuts).
 - [x] Several installation types : Full, Standard, Minimal and Custom.
 - [x] Automatic JRE (Java Runtime Edition) detection. If the JRE isn't installed,  
   a dialog allows the user to choose between a manual or automatic install.  
 - [x] System language detection to preselect Linguistic Resources to install.
 - [x] Same, older or newer version detection.
 - [x] Application, Manual, and Web links shortcuts.
 - [x] Admin or user installation mode support.
 - [x] Mixed-mode installer that can both be installed per-machine or per-user.
 - [x] Silent mode support for batch installs.
 - [x] Uninstall support.
 - [ ] Support for a web installation mode. 
 - [ ] Check for updates.
 - [ ] User interface i18n.
 - [ ] Include support for creating pure 64-bit Windows installers.

### Contributing

We welcome everyone to contribute to improve this project. Below are some of the
things that you can do to contribute:

-  [Fork us](https://github.com/UnitexGramLab/unitex-packaging-windows/fork) and [request a pull](https://github.com/UnitexGramLab/unitex-packaging-windows/pulls) to the [develop branch](https://github.com/UnitexGramLab/unitex-packaging-windows/tree/develop).
-  Submit [bug reports or feature requests](https://github.com/UnitexGramLab/unitex-packaging-windows/issues)

### Licensing information
This program is licensed under the [GNU Lesser General Public License version 2.1](/LICENSE). Contact unitex-devel@univ-mlv.fr for further inquiries.

Copyright (C) 2014-2015 Université Paris-Est Marne-la-Vallée

[nsis]:   http://nsis.sourceforge.net
[unitex]: http://unitexgramlab.org
