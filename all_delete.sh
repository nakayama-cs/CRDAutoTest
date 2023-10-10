#!/bin/bash

# 共通関数をインポートする
source ./auto_test_lib.sh

# 自動テスト実行のための環境が構築されていない場合はこの行でアサートする
autoTestAssertIfNotSupported

# 実行ファイルのパス設定
autoTestConfigExecPath "../cmd/mtechnavi-cli/"

# パラメータ
service="mtechnavi.api.company.BusinessUnitManagementService"
endpoint_contact_header="BusinessUnitContactHeader"
endpoint_contact_attribute="BusinessUnitContactAttribute"
endpoint_contact="BusinessUnitContact"
json_object_name="business_unit_contact"
json_object_id_name="business_unit_contact_id"
json_object_management_id_name="business_unit_management_id"
host_info="http://localhost:8000"

list_json=$(autoTestExecGrpcurlList "$service" "$endpoint_contact_header" empty.json "$host_info")
total=$(echo $list_json | jq -r '.total')
total=$(expr $total - 1)
echo $total
for i in `seq 0 ${total}`
do
    id=$(echo $list_json | jq -r ".items[$i].businessUnitContactHeaderId")
    updateAt=$(echo $list_json | jq -r ".items[$i].updatedAt")
    echo "{\"business_unit_contact_header\": {\"business_unit_contact_header_id\": \"$id\", \"updated_at\": $updateAt}}" > delete.json
    autoTestExecGrpcurlDelete "$service" "$endpoint_contact_header" delete.json "$host_info" > /dev/null 2>&1
done
