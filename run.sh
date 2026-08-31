#!/bin/sh

julia --threads auto --project --sysimage test-runner-sysimage.so run.jl "$1" "$2" "$3"
