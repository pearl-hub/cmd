CMD
===

|Project Status|Communication|
|:-----------:|:-----------:|
|[![Build status](https://api.travis-ci.org/pearl-hub/cmd.png?branch=master)](https://travis-ci.org/pearl-hub/cmd) | [![Join the gitter chat at https://gitter.im/pearl-core/pearl](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/pearl-core/pearl?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) |

**Table of Contents**
- [Description](#description)
- [Quickstart](#quickstart)
- [Installation](#installation)
- [Troubleshooting](#troubleshooting)

Description
===========

- name: `cmd`
- description: Store your favourite commands and scripts in one place.
- author: Filippo Squillace
- username: fsquillace
- OS compatibility: linux, osx

Quickstart
==========

- To add/update a new command/script:

```sh
$ cmd add myls
Write the script below and press Cntrl-c on a new line to save it:
ls -l ~
```

- To add/update a new command/script with variables in it:

```sh
$ cmd add myls
Write the script below and press Cntrl-c on a new line to save it:
ls -l $opts $@
```

- To execute the command/script:

```sh
$ cmd execute myls
ls -l ~
Are you sure to run the script? (N/y)> y
...
...
```

- To execute the command/script substituting variables:

```sh
$ cmd execute myls "opts='-a -lt'" /root
ls -l $opts $@
Are you sure to run the script? (N/y)> y
...
...
```

- To list all the available commands:

```sh
$ cmd list
myls
```

Attach existing commands
------------------------
If there are already existing commands in a given directory, you can use the
variable environment `CMD_PATH` to include such commands into `cmd` program:

```sh
export CMD_PATH="/mydirectory/to/new/commands:$CMD_PATH"
cmd list
```

Installation
============
This package needs to be installed via [Pearl](https://github.com/pearl-core/pearl) system.

```sh
pearl install cmd
```

Optionally, you can also install the package `cmd-extra` containing a collection of standard commands:

```sh
pearl install cmd-extra
```


Dependencies
------------
The main dependencies are the following:

- [Pearl](https://github.com/pearl-core/pearl)
- [GNU coreutils](https://www.gnu.org/software/coreutils/)

Troubleshooting
===============
This section has been left blank intentionally.
It will be filled up as soon as troubles come in!

