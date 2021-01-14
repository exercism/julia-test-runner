#!/bin/sh

julia --compile=min -O0 --project --sysimage test-runner-sysimage.so run.jl "$1" "$2" "$3"
