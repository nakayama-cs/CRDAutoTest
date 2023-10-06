#!/bin/bash

function autoTestAssertIfNotSupported() {
    if ! command -v go &>/dev/null; then
        autoTestAssertAlways "go hasn't installed"
    fi

    if ! command -v sed &>/dev/null; then
        autoTestAssertAlways "sed hasn't installed"
    fi
}

function autoTestAssertAlways() {
    echo "ASSERTED: "$1
    exit 1
}

function autoTestAssertIfEmptyString() {
    if [ -z "$1" ]; then
        autoTestAssertAlways $2
    fi
}

function autoTestAssertIfNotEmptyString() {
    if [ ! -z "$1" ]; then
        autoTestAssertAlways $2
    fi
}

function autoTestAssertIfEquals() {
    if [ "$1" = "$2" ]; then
        autoTestAssertAlways $3
    fi
}

function autoTestAssertIfNotEquals() {
    if [ "$1" != "$2" ]; then
        autoTestAssertAlways $3
    fi
}
