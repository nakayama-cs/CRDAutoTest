#!/bin/bash

# 共通関数をインポートする
source ./auto_test_lib.sh

# 自動テスト実行のための環境が構築されていない場合はこの行でアサートする
autoTestAssertIfNotSupported

# 実行ファイルのパス設定
autoTestConfigExecPath "../cmd/mtechnavi-cli/"

# パラメータ
service="mtechnavi.api.company.BusinessUnitManagementService"
endpoint="BusinessUnitContactAttribute"
json_object_name="business_unit_contact_attribute"
json_object_id_name="business_unit_contact_attribute_id"
json_object_management_id_name="business_unit_management_id"
result_json_id_name="businessUnitContactAttributeId"
host_info="http://localhost:8000"

echo '{}' > auto_test_empty.json
echo "{\"${json_object_name}\": {\"business_unit_management_id\": \"1\"}}" > auto_test_create.json

# 現在のリストを取得
list_json=$(autoTestExecGrpcurlList "$service" "$endpoint" auto_test_empty.json "$host_info")
autoTestAssertIfEmptyString "$list_json" "LISTに失敗しました"
total_before=$(autoTestGet "$list_json" ".total")

# auto_test_create.jsonで新規レコードを作成
create_json=$(autoTestExecGrpcurlCreate "$service" "$endpoint" auto_test_create.json "$host_info")
autoTestAssertIfEmptyString "$create_json" "CREATE(auto_test_create.json)に失敗しました"
json_id=$(autoTestGet "$create_json" ".${result_json_id_name}")

# 作成後にリストを取得
list_json=$(autoTestExecGrpcurlList "$service" "$endpoint" auto_test_empty.json "$host_info")
autoTestAssertIfEmptyString "$list_json" "LISTに失敗しました"

# カウント値が予期した数値になっていることを確認する
expect_after_total=$(expr $total_before + 1)
has=$(autoTestExistsValue "$list_json" ".total" "$expect_after_total")
total_after=$(autoTestGet "$list_json" ".total")
autoTestAssertIfEmptyString "$has" "totalに予期しない値が格納されています:${total_after}"

# リスト内に新規作成したIDが存在するかを確認する
has=$(autoTestExistsValue "$list_json" ".items[].${result_json_id_name}" "$json_id")
autoTestAssertIfEmptyString "$has" "auto_test_create.jsonで作成した新規IDがリストに存在しませんでした"

# GET用jsonを作成する
echo "{\"${json_object_id_name}\": \"${json_id}\" }" > auto_test_get.json

# GETを実行してupdatedAtとdeletedAtのタイムスタンプを確認する
get_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" auto_test_get.json "$host_info")
autoTestAssertIfEmptyString "$get_json" "auto_test_get.jsonでのGETに失敗しました"
get_updatedAt=$(autoTestGet "$get_json" ".updatedAt")
autoTestAssertIfEquals "$get_updatedAt" "0" "auto_test_get.jsonで取得したレコードの更新時間が0になっています"
get_deletedAt=$(autoTestGet "$get_json" ".deletedAt")
autoTestAssertIfNotEquals "$get_deletedAt" "0" "auto_test_get.jsonで取得したレコードの削除時間が0以外になっています"

# 作成したレコードを削除する
echo "{\"${json_object_name}\": {\"${json_object_id_name}\": \"${json_id}\", \"updated_at\": \"${get_updatedAt}\" }}" > auto_test_delete.json
autoTestExecGrpcurlDelete "$service" "$endpoint" auto_test_delete.json "$host_info" > /dev/null 2>&1

# 削除後に再度GETを実行してdeletedAtのタイムスタンプを確認する
get_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" auto_test_get.json "$host_info")
autoTestAssertIfEmptyString "$get_json" "auto_test_get.jsonでのGETに失敗しました"
get_deletedAt=$(autoTestGet "$get_json" ".deletedAt")
autoTestAssertIfEquals "$get_deletedAt" "0" "[削除後]auto_test_get.jsonで取得したレコードの削除時間が0になっています"

# 削除後に再度LISTを実行して作成したIDの存在の有無とtotalを確認する
list_json=$(autoTestExecGrpcurlList "$service" "$endpoint" auto_test_empty.json "$host_info")
autoTestAssertIfEmptyString "$list_json" "LISTに失敗しました"
total_after_delete=$(autoTestGet "$list_json" ".total")

# 新規作成したIDがリストに存在しているか確認する
has1=$(autoTestExistsValue "$list_json" ".items[].businessUnitContactId" "$json_id")
autoTestAssertIfNotEmptyString "$has1" "[削除後]auto_test_create.jsonで作成したレコードがリストにまだ存在しています"

# テストで使用したjsonを削除する
rm auto_test_*.json

echo "PASSED $endpoint"
