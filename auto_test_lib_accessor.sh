#!/bin/bash

function autoTestGetFirst() {
    echo $(echo $1 | sed -n "s/.*\(\"${2}\":\) \"\([^\"]*\)\".*/\2/p")
}

function autoTestGetLast() {
    echo $(echo $1 | sed -nE "s/.*\"${2}\":\s*\"([^\"]*)\".*/\1/p" | tail -n 1)
}

function autoTestHasKeyValue() {
    echo $(echo $1 | sed -nE "s/.*\"${2}\":\s*\"(${3})\".*/\1/p" | tail -n 1)
}
