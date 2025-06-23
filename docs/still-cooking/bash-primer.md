---
title: Bash Primer
tags:
  - bash
---

### Finding a command

The bash builtin type command searches your environment (including aliases, keywords, functions, builtins, directories in $PATH, and the command hash table) for executable commands unlike the `which` command:

```
$ type ls -a
ls is an alias for ls -G
ls is /bin/ls
```

### Can't remember the exact command name

```
man -k movie
```

### Find files

locate and slocate consult database files about the system 
```
$ locate ls

# Only show programs the user has access to
$ slocate ls
```

### Find information about a file

```
$ stat test.log
  File: test.log
  Size: 6950      	Blocks: 16         IO Block: 4096   regular file
Device: 10301h/66305d	Inode: 259552      Links: 1
Access: (0660/-rw-rw----)  Uid: ( 1000/  ubuntu)   Gid: ( 1000/  ubuntu)
Access: 2024-05-03 06:25:18.293530773 +1000
Modify: 2024-01-31 18:35:17.855147535 +1100
Change: 2024-01-31 18:35:17.855147535 +1100
 Birth: 2024-01-31 18:15:34.763925028 +1100
```

### Show only dot files in a directory

Every normal directory contains a `.` and `..`. Ignore this with `la -A`.

```
shows contents of the .ansible directory including . and ..
$ ls -a .ansible 


$ ls -d .ansible
.ansible
```


```
$ ls -d .*
$ ls -d .b*
```


### Search: Positive look ahead

Say you have the following content in a file:

```
## Heading A

### Heading B
```

Now to change `##` to `###` use a lookahead for the match but not include it in the search result because you don't want
include the empty char in the search that follows from the `#` to heading string.

```
(?=) : postivie lookahead
^##(?=\s)
```

