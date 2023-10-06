#!/bin/bash

function autoTestGet() {
    echo $(echo $1 | jq -r $2)
}

function autoTestHasKeyValue() {
    echo $(echo $1 | sed -nE "s/.*\"${2}\":\s*\"(${3})\".*/\1/p" | tail -n 1)
}

