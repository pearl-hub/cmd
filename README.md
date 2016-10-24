CMD
===

|Project Status|Communication|
|:-----------:|:-----------:|
|[![Build status](https://api.travis-ci.org/pearl-hub/cmd.png?branch=master)](https://travis-ci.org/pearl-hub/cmd) | [![Join the gitter chat at https://gitter.im/pearl-hub/cmd](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/pearl-hub/cmd?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) |

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

Installation
============
This package needs to be installed via [Pearl](https://github.com/pearl-core/pearl) system.

```sh
pearl install cmd
```

Dependencies
------------
The main dependencies are the following:

- [Pearl](https://github.com/pearl-core/pearl)

Troubleshooting
===============
This section has been left blank intentionally.
It will be filled up as soon as troubles come in!

