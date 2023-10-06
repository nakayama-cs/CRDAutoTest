#!/bin/bash

function autoTestExecGrpcurlList() {
    service=$1
    endpoint=$2
    json_file=$3
    host_info=$4
    echo $(go run ./cmd/mtechnavi-cli/ grpcurl ${service}/List${endpoint}s @${json_file} -u ${host_info} -s)
}

function autoTestExecGrpcurlGet() {
    service=$1
    endpoint=$2
    json_file=$3
    host_info=$4
    echo $(go run ./cmd/mtechnavi-cli/ grpcurl ${service}/Get${endpoint} @${json_file} -u ${host_info} -s)
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
    echo $(go run ./cmd/mtechnavi-cli/ grpcurl ${service}/Update${endpoint} @${json_file} -u ${host_info} -s)
}
