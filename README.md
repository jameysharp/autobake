autobake
========

_Create build recipes through automated trial and error._

Packaging a random piece of software for any given Linux distribution
often involves a process like this:

1. Guess at some build dependencies.
2. Try building the package with those dependencies.
3. Discover that you missed some more dependencies.
4. Repeat, _ad nauseum_.

This project partially automates that cycle.

1. During a test build, autobake watches which files the build process
   tries and fails to open.
2. After the build finishes (whether successful or not), autobake looks
   for packages which contain the missing files.
3. Not yet implemented: autobake should update your package with the
   additional dependencies.
4. In many cases, there's only one package providing a given file, so
   autobake can repeat this process without any human intervention.

This approach may over-estimate the build dependencies, when build
systems check for the existence of software they don't actually need.
Fortunately, it take a lot less work to remove dependencies by hand than
it does to guess which packages _might_ be necessary.


Supported platforms
===================

This is an early prototype. So far I have only implemented support for
the [Nix][] package manager, using only the [Nix Packages
collection][nixpkgs], and only on Linux. The approach is quite flexible,
though, and should work for most systems. I'd love to get patches adding
support for other platforms!

[Nix]: https://nixos.org/nix/
[nixpkgs]: https://nixos.org/nixpkgs/

The build agent, which runs inside the package build process, should
work on any OS which can run [strace][]. However the concept should
apply to any OS which allows tracing system calls. I think FreeBSD,
Solaris, and MacOS X should be supportable using `truss`, for example.

[strace]: https://strace.io/

To support a specific package manager and distribution, you need two
things:

1. A way to sandbox builds, such that only the specified build
   dependencies are available in the sandbox. Nix builds always work
   this way, but tools exist for other package managers. For example,
   for RPM there's [mock][].

2. A way to search for packages containing files which end with a given
   fragment, such as `/dbus/dbus.h`. For Nixpkgs I used [nix-index][],
   but again, tools exist for other package managers. For example, for
   Debian, there's [apt-file][].

[mock]: https://github.com/rpm-software-management/mock
[nix-index]: https://github.com/bennofs/nix-index
[apt-file]: https://wiki.debian.org/apt-file


Usage
=====

For the initial Nix-only prototype, just run `autobake-nix` with a
single Nix expression, which must evaluate to a derivation. For example,
this command will build the GNU Multiple Precision arithmetic library
(GMP), but without providing `m4`, which it needs:

```sh
autobake-nix '(import <nixpkgs> {}).gmp.overrideDerivation (oldAttrs: { nativeBuildInputs = []; })'
```

Because `gmp` uses `autoconf`, its build process checks for a large
number of unnecessary programs, which autobake tries to satisfy, so
you'll see suggestions for a lot more than just `gnum4.out`.


License
=======

This work is licensed under the [GNU Affero GPL version 3][AGPLv3].

[AGPLv3]: https://www.gnu.org/licenses/agpl-3.0.html
