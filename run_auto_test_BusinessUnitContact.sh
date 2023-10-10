#!/bin/bash

# 共通関数をインポートする
source ./auto_test_lib.sh

# 自動テスト実行のための環境が構築されていない場合はこの行でアサートする
autoTestAssertIfNotSupported

# パラメータ
service="mtechnavi.api.company.BusinessUnitManagementService"
endpoint="BusinessUnitContact"
json_file="auto_test_empty.json"
host_info="http://localhost:8000"

# 各バリエーションごとにjsonファイルを作成
echo '{}' > auto_test_empty.json
echo '{"business_unit_contact": {"company_id": "1", "business_unit_management_id": "1"}}' > auto_test_create1.json
echo '{"business_unit_contact": {"company_id": "1", "business_unit_management_id": "2"}}' > auto_test_create2.json
echo '{"business_unit_contact": {"company_id": "2", "business_unit_management_id": "1"}}' > auto_test_create3.json
echo '{"business_unit_contact": {"company_id": "2", "business_unit_management_id": "2"}}' > auto_test_create4.json

# 作成前にリストを取得
list_json=$(autoTestExecGrpcurlList "$service" "$endpoint" auto_test_empty.json "$host_info")
autoTestAssertIfEmptyString "$list_json" "LISTに失敗しました"
total_before=$(autoTestGet "$list_json" ".total")

echo "リストのtotal:"$total_before

# auto_test_create1.jsonで新規レコードを作成
json1=$(autoTestExecGrpcurlCreate "$service" "$endpoint" auto_test_create1.json "$host_info")
autoTestAssertIfEmptyString "$json1" "CREATE(auto_test_create1.json)に失敗しました"
json1_id=$(autoTestGet "$json1" ".businessUnitContactId")

# auto_test_create2.jsonで新規レコードを作成
json2=$(autoTestExecGrpcurlCreate "$service" "$endpoint" auto_test_create2.json "$host_info")
autoTestAssertIfEmptyString "$json2" "CREATE(auto_test_create2.json)に失敗しました"
json2_id=$(autoTestGet "$json2" ".businessUnitContactId")

# auto_test_create3.jsonで新規レコードを作成
json3=$(autoTestExecGrpcurlCreate "$service" "$endpoint" auto_test_create3.json "$host_info")
autoTestAssertIfEmptyString "$json3" "CREATE(auto_test_create3.json)に失敗しました"
json3_id=$(autoTestGet "$json3" ".businessUnitContactId")

# auto_test_create4.jsonで新規レコードを作成
json4=$(autoTestExecGrpcurlCreate "$service" "$endpoint" auto_test_create4.json "$host_info")
autoTestAssertIfEmptyString "$json4" "CREATE(auto_test_create4.json)に失敗しました"
json4_id=$(autoTestGet "$json4" ".businessUnitContactId")

# 作成後にリストを取得
list_json=$(autoTestExecGrpcurlList "$service" "$endpoint" auto_test_empty.json "$host_info")
autoTestAssertIfEmptyString "$list_json" "LISTに失敗しました"

# カウント値が予期した数値になっていることを確認する
expect_after_total=$(expr $total_before + 4)
has=$(autoTestExistsValue "$list_json" ".total" "$expect_after_total")
total_after=$(autoTestGet "$list_json" ".total")
autoTestAssertIfEmptyString "$has" "totalに予期しない値が格納されています:${total_after}"

echo "リストのtotal(CRATE後):"$total_after

# リスト内に新規作成したIDが存在するかを確認する
has1=$(autoTestExistsValue "$list_json" ".items[].businessUnitContactId" "$json1_id")
has2=$(autoTestExistsValue "$list_json" ".items[].businessUnitContactId" "$json2_id")
has3=$(autoTestExistsValue "$list_json" ".items[].businessUnitContactId" "$json3_id")
has4=$(autoTestExistsValue "$list_json" ".items[].businessUnitContactId" "$json4_id")
autoTestAssertIfEmptyString "$has1" "auto_test_create1.jsonで作成した新規IDがリストに存在しませんでした"
autoTestAssertIfEmptyString "$has2" "auto_test_create2.jsonで作成した新規IDがリストに存在しませんでした"
autoTestAssertIfEmptyString "$has3" "auto_test_create3.jsonで作成した新規IDがリストに存在しませんでした"
autoTestAssertIfEmptyString "$has4" "auto_test_create4.jsonで作成した新規IDがリストに存在しませんでした"

# Delete用の.jsonを作成する

echo "{\"business_unit_contact_id\": \"${json1_id}\" }" > auto_test_get1.json
echo "{\"business_unit_contact_id\": \"${json2_id}\" }" > auto_test_get2.json
echo "{\"business_unit_contact_id\": \"${json3_id}\" }" > auto_test_get3.json
echo "{\"business_unit_contact_id\": \"${json4_id}\" }" > auto_test_get4.json

# GETを実行してupdatedAtとdeletedAtのタイムスタンプを確認する
get1_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" auto_test_get1.json "$host_info")
get2_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" auto_test_get2.json "$host_info")
get3_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" auto_test_get3.json "$host_info")
get4_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" auto_test_get4.json "$host_info")

autoTestAssertIfEmptyString "$get1_json" "auto_test_get1.jsonでのGETに失敗しました"
autoTestAssertIfEmptyString "$get2_json" "auto_test_get2.jsonでのGETに失敗しました"
autoTestAssertIfEmptyString "$get3_json" "auto_test_get3.jsonでのGETに失敗しました"
autoTestAssertIfEmptyString "$get4_json" "auto_test_get4.jsonでのGETに失敗しました"

get1_updatedAt=$(autoTestGet "$get1_json" ".updatedAt")
get2_updatedAt=$(autoTestGet "$get2_json" ".updatedAt")
get3_updatedAt=$(autoTestGet "$get3_json" ".updatedAt")
get4_updatedAt=$(autoTestGet "$get4_json" ".updatedAt")

autoTestAssertIfEquals "$get1_updatedAt" "0" "auto_test_get1.jsonで取得したレコードの更新時間が0になっています"
autoTestAssertIfEquals "$get2_updatedAt" "0" "auto_test_get2.jsonで取得したレコードの更新時間が0になっています"
autoTestAssertIfEquals "$get3_updatedAt" "0" "auto_test_get3.jsonで取得したレコードの更新時間が0になっています"
autoTestAssertIfEquals "$get4_updatedAt" "0" "auto_test_get4.jsonで取得したレコードの更新時間が0になっています"

get1_deletedAt=$(autoTestGet "$get1_json" ".deletedAt")
get2_deletedAt=$(autoTestGet "$get2_json" ".deletedAt")
get3_deletedAt=$(autoTestGet "$get3_json" ".deletedAt")
get4_deletedAt=$(autoTestGet "$get4_json" ".deletedAt")

autoTestAssertIfNotEquals "$get1_deletedAt" "0" "auto_test_get1.jsonで取得したレコードの削除時間が0以外になっています"
autoTestAssertIfNotEquals "$get2_deletedAt" "0" "auto_test_get2.jsonで取得したレコードの削除時間が0以外になっています"
autoTestAssertIfNotEquals "$get3_deletedAt" "0" "auto_test_get3.jsonで取得したレコードの削除時間が0以外になっています"
autoTestAssertIfNotEquals "$get4_deletedAt" "0" "auto_test_get4.jsonで取得したレコードの削除時間が0以外になっています"

# company_idsでLISTを取得する

## company_id=1で検索する
echo '{"company_ids": ["1"]}' > auto_test_list_company1.json
list_json=$(autoTestExecGrpcurlList "$service" "$endpoint" auto_test_list_company1.json "$host_info")
has_another=$(autoTestContainAnother "$list_json" ".items[].companyId" "1")
autoTestAssertIfNotEmptyString "$has_another" "auto_test_list_company1.jsonで取得したリストに、companyIdが1以外のデータが存在しました"

## company_id=1or2で検索する
echo '{"company_ids": ["1", "2"]}' > auto_test_list_company1_or_2.json
list_json=$(autoTestExecGrpcurlList "$service" "$endpoint" auto_test_list_company1_or_2.json "$host_info")
has_another=$(autoTestContainAnother "$list_json" ".items[].companyId" "1\|2")
autoTestAssertIfNotEmptyString "$has_another" "auto_test_list_company1_or_2.jsonで取得したリストに、companyIdが1または2以外のデータが存在しました"

# business_unit_management_idsでLISTを取得する

## business_unit_management_id=1で検索する
echo '{"business_unit_management_ids": ["1"]}' > auto_test_list_business_unit_management1.json
list_json=$(autoTestExecGrpcurlList "$service" "$endpoint" auto_test_list_business_unit_management1.json "$host_info")
has_another=$(autoTestContainAnother "$list_json" ".items[].businessUnitManagementId" "1")
autoTestAssertIfNotEmptyString "$has_another" "auto_test_list_business_unit_management1.jsonで取得したリストに、businessUnitManagementIdが1以外のデータが存在しました"

## business_unit_management_id=1or2で検索する
echo '{"business_unit_management_ids": ["1", "2"]}' > auto_test_list_business_unit_management1_or_2.json
list_json=$(autoTestExecGrpcurlList "$service" "$endpoint" auto_test_list_business_unit_management1_or_2.json "$host_info")
has_another=$(autoTestContainAnother "$list_json" ".items[].businessUnitManagementId" "1\|2")
autoTestAssertIfNotEmptyString "$has_another" "auto_test_list_business_unit_management1_or_2.jsonで取得したリストに、businessUnitManagementIdが1または2以外のデータが存在しました"

# 作成したレコードを削除する
echo "{\"business_unit_contact\": {\"business_unit_contact_id\": \"${json1_id}\", \"updated_at\": \"${get1_updatedAt}\" }}" > auto_test_delete1.json
echo "{\"business_unit_contact\": {\"business_unit_contact_id\": \"${json2_id}\", \"updated_at\": \"${get2_updatedAt}\" }}" > auto_test_delete2.json
echo "{\"business_unit_contact\": {\"business_unit_contact_id\": \"${json3_id}\", \"updated_at\": \"${get3_updatedAt}\" }}" > auto_test_delete3.json
echo "{\"business_unit_contact\": {\"business_unit_contact_id\": \"${json4_id}\", \"updated_at\": \"${get4_updatedAt}\" }}" > auto_test_delete4.json

autoTestExecGrpcurlDelete "$service" "$endpoint" auto_test_delete1.json "$host_info" > /dev/null 2>&1
autoTestExecGrpcurlDelete "$service" "$endpoint" auto_test_delete2.json "$host_info" > /dev/null 2>&1
autoTestExecGrpcurlDelete "$service" "$endpoint" auto_test_delete3.json "$host_info" > /dev/null 2>&1
autoTestExecGrpcurlDelete "$service" "$endpoint" auto_test_delete4.json "$host_info" > /dev/null 2>&1

# 削除後に再度GETを実行してdeletedAtのタイムスタンプを確認する
get1_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" auto_test_get1.json "$host_info")
get2_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" auto_test_get2.json "$host_info")
get3_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" auto_test_get3.json "$host_info")
get4_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" auto_test_get4.json "$host_info")

autoTestAssertIfEmptyString "$get1_json" "auto_test_get1.jsonでのGETに失敗しました"
autoTestAssertIfEmptyString "$get2_json" "auto_test_get2.jsonでのGETに失敗しました"
autoTestAssertIfEmptyString "$get3_json" "auto_test_get3.jsonでのGETに失敗しました"
autoTestAssertIfEmptyString "$get4_json" "auto_test_get4.jsonでのGETに失敗しました"

get1_deletedAt=$(autoTestGet "$get1_json" ".deletedAt")
get2_deletedAt=$(autoTestGet "$get2_json" ".deletedAt")
get3_deletedAt=$(autoTestGet "$get3_json" ".deletedAt")
get4_deletedAt=$(autoTestGet "$get4_json" ".deletedAt")

autoTestAssertIfEquals "$get1_deletedAt" "0" "[削除後]auto_test_get1.jsonで取得したレコードの削除時間が0になっています"
autoTestAssertIfEquals "$get2_deletedAt" "0" "[削除後]auto_test_get2.jsonで取得したレコードの削除時間が0になっています"
autoTestAssertIfEquals "$get3_deletedAt" "0" "[削除後]auto_test_get3.jsonで取得したレコードの削除時間が0になっています"
autoTestAssertIfEquals "$get4_deletedAt" "0" "[削除後]auto_test_get4.jsonで取得したレコードの削除時間が0になっています"

# 削除後に再度LISTを実行して作成したIDの存在の有無とtotalを確認する
list_json=$(autoTestExecGrpcurlList "$service" "$endpoint" auto_test_empty.json "$host_info")
autoTestAssertIfEmptyString "$list_json" "LISTに失敗しました"
total_after_delete=$(autoTestGet "$list_json" ".total")

echo "リストのtotal(DELETE後):"$total_after_delete

# 新規作成したIDがリストに存在しているか確認する
has1=$(autoTestExistsValue "$list_json" ".items[].businessUnitContactId" "$json1_id")
has2=$(autoTestExistsValue "$list_json" ".items[].businessUnitContactId" "$json2_id")
has3=$(autoTestExistsValue "$list_json" ".items[].businessUnitContactId" "$json3_id")
has4=$(autoTestExistsValue "$list_json" ".items[].businessUnitContactId" "$json4_id")

autoTestAssertIfNotEmptyString "$has1" "[削除後]auto_test_create1.jsonで作成したレコードがリストにまだ存在しています"
autoTestAssertIfNotEmptyString "$has2" "[削除後]auto_test_create2.jsonで作成したレコードがリストにまだ存在しています"
autoTestAssertIfNotEmptyString "$has3" "[削除後]auto_test_create3.jsonで作成したレコードがリストにまだ存在しています"
autoTestAssertIfNotEmptyString "$has4" "[削除後]auto_test_create4.jsonで作成したレコードがリストにまだ存在しています"

# テストで使用したjsonを削除する
rm auto_test_*.json

echo "PASSED BusinessUnitContact"
