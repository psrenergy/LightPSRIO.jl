#!/bin/bash
set -e

BASEPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$JULIA_1120 --project=$BASEPATH $BASEPATH/publish.jl $@
