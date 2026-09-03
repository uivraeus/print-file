# print-file - too simple?

A very simple and limited tool for printing the content of a file to stdout.

## Why?

The intended use-case is to enable this capability in environments where there is no shell and no standard Lin available, e.g. a "distro-less" or "scratch" container. This include:

* Static linking - don√'t assume anything about the distro in which it will operate
* Minimal - don't add unnecessary feature and capability to a intentionally reduced/limited system

## What?

The tool takes one argument, the full path file name. It then prints the entire content to stdout.

Nothing more, i.e.:

* No support for printing multiple files
* No su√pport for globbing
* No support for relative paths

Error handling:

* String on stderr
* Basic cases like "Permission denied" and "File not found"
* Return code: 1

## How?

This tool is packaged into an OCI image (without anything else in it). This allows for easy integration into Kubernetes Pods where OCI images can be mounted as Volumes directly.

