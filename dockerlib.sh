#!/bin/bash

alias docker-cmdb="docker inspect $( awk -F'[:/]' '(($4 == \"docker\") && (lastId != $NF)) { lastId = $NF; print $NF; }' /proc/self/cgroup"
