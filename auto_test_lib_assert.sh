#!/bin/bash

function autoTestAssertIfNotSupported() {
    if ! command -v go &>/dev/null; then
        autoTestAssertAlways "go is not installed"
    fi

    if ! command -v sed &>/dev/null; then
        autoTestAssertAlways "sed is not installed"
    fi

    if ! command -v jq &>/dev/null; then
        autoTestAssertAlways "jq is not installed"
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
