#!/bin/sh

julia --project --sysimage test-runner-sysimage.so run.jl "$1" "$2" "$3"
