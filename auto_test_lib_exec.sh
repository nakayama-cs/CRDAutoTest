#!/bin/bash

function extractJson() {
    echo $1 | sed -z "s/\n//g" | sed -n "s/.*Response contents:\s*\({.*}\).*/\1/p"
}

function autoTestExecGrpcurlList() {
    service=$1
    endpoint=$2
    json_file=$3
    host_info=$4
    result=$(go run ./cmd/mtechnavi-cli/ grpcurl ${service}/List${endpoint}s @${json_file} -u ${host_info} -s)
    echo $(extractJson "$result")
}

function autoTestExecGrpcurlGet() {
    service=$1
    endpoint=$2
    json_file=$3
    host_info=$4
    result=$(go run ./cmd/mtechnavi-cli/ grpcurl ${service}/Get${endpoint} @${json_file} -u ${host_info} -s)
    echo $(extractJson "$result")
}

function autoTestExecGrpcurlDelete() {
    service=$1
    endpoint=$2
    json_file=$3
    host_info=$4
    echo $(go run ./cmd/mtechnavi-cli/ grpcurl ${service}/Delete${endpoint} @${json_file} -u ${host_info} -s)
}

function autoTestExecGrpcurlUpdate() {
    service=$1
    endpoint=$2
    json_file=$3
    host_info=$4
    result=$(go run ./cmd/mtechnavi-cli/ grpcurl ${service}/Update${endpoint} @${json_file} -u ${host_info} -s)
    echo $(extractJson "$result")
}

function autoTestExecGrpcurlCreate() {
    service=$1
    endpoint=$2
    json_file=$3
    host_info=$4
    result=$(go run ./cmd/mtechnavi-cli/ grpcurl ${service}/Create${endpoint} @${json_file} -u ${host_info} -s)
    echo $(extractJson "$result")
}