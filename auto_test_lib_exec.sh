#!/bin/bash

function extractJson() {
    echo $1 | sed -z "s/\n//g" | sed -n "s/.*Response contents:\s*\({.*}\).*/\1/p"
}

function autoTestExportExecPath() {
    export EXEC_PATH=$1
}

function autoTestExecGrpcurlList() {
    service=$1
    endpoint=$2
    json_file=$3
    host_info=$4
    result=$(go run ${EXEC_PATH} grpcurl ${service}/List${endpoint}s @${json_file} -u ${host_info} -s)
    echo $(extractJson "$result")
}

function autoTestExecGrpcurlGet() {
    service=$1
    endpoint=$2
    json_file=$3
    host_info=$4
    result=$(go run ${EXEC_PATH} grpcurl ${service}/Get${endpoint} @${json_file} -u ${host_info} -s)
    echo $(extractJson "$result")
}

function autoTestExecGrpcurlDelete() {
    service=$1
    endpoint=$2
    json_file=$3
    host_info=$4
    echo $(go run ${EXEC_PATH} grpcurl ${service}/Delete${endpoint} @${json_file} -u ${host_info} -s)
}

function autoTestExecGrpcurlUpdate() {
    service=$1
    endpoint=$2
    json_file=$3
    host_info=$4
    result=$(go run ${EXEC_PATH} grpcurl ${service}/Update${endpoint} @${json_file} -u ${host_info} -s)
    echo $(extractJson "$result")
}

function autoTestExecGrpcurlCreate() {
    service=$1
    endpoint=$2
    json_file=$3
    host_info=$4
    result=$(go run ${EXEC_PATH} grpcurl ${service}/Create${endpoint} @${json_file} -u ${host_info} -s)
    echo $(extractJson "$result")
}