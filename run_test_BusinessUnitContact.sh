#!/bin/bash

# 共通関数をインポートする
source ./auto_test_lib.sh

# 自動テスト実行のための環境が構築されていない場合はこの行でアサートする
autoTestAssertIfNotSupported

# パラメータ
service="mtechnavi.api.company.BusinessUnitManagementService"
endpoint="BusinessUnitContact"
json_file="empty.json"
host_info="http://localhost:8000"

# 各バリエーションごとにjsonファイルを作成
echo '{}' > empty.json
echo '{"business_unit_contact": {"company_id": "1", "business_unit_management_id": "1"}}' > create1.json
echo '{"business_unit_contact": {"company_id": "1", "business_unit_management_id": "2"}}' > create2.json
echo '{"business_unit_contact": {"company_id": "2", "business_unit_management_id": "1"}}' > create3.json
echo '{"business_unit_contact": {"company_id": "2", "business_unit_management_id": "2"}}' > create4.json

# 作成前にリストを取得
list_json=$(autoTestExecGrpcurlList "$service" "$endpoint" empty.json "$host_info")
autoTestAssertIfEmptyString "$list_json" "LISTに失敗しました"
total_before=$(autoTestGet "$list_json" ".total")

echo "リストのtotal:"$total_before

# create1.jsonで新規レコードを作成
json1=$(autoTestExecGrpcurlCreate "$service" "$endpoint" create1.json "$host_info")
autoTestAssertIfEmptyString "$json1" "CREATE(create1.json)に失敗しました"
json1_id=$(autoTestGet "$json1" ".businessUnitContactId")

# create2.jsonで新規レコードを作成
json2=$(autoTestExecGrpcurlCreate "$service" "$endpoint" create2.json "$host_info")
autoTestAssertIfEmptyString "$json2" "CREATE(create2.json)に失敗しました"
json2_id=$(autoTestGet "$json2" ".businessUnitContactId")

# create3.jsonで新規レコードを作成
json3=$(autoTestExecGrpcurlCreate "$service" "$endpoint" create3.json "$host_info")
autoTestAssertIfEmptyString "$json3" "CREATE(create3.json)に失敗しました"
json3_id=$(autoTestGet "$json3" ".businessUnitContactId")

# create4.jsonで新規レコードを作成
json4=$(autoTestExecGrpcurlCreate "$service" "$endpoint" create4.json "$host_info")
autoTestAssertIfEmptyString "$json4" "CREATE(create4.json)に失敗しました"
json4_id=$(autoTestGet "$json4" ".businessUnitContactId")

# 作成後にリストを取得
list_json=$(autoTestExecGrpcurlList "$service" "$endpoint" empty.json "$host_info")
autoTestAssertIfEmptyString "$list_json" "LISTに失敗しました"

# カウント値が予期した数値になっていることを確認する
expect_after_total=$(expr $total_before + 4)
has=$(autoTestHasKeyValue "$list_json" "total" "$expect_after_total")
total_after=$(autoTestGet "$list_json" ".total")
autoTestAssertIfEmptyString "$has" "totalに予期しない値が格納されています:${total_after}"

echo "リストのtotal(CRATE後):"$total_after

# リスト内に新規作成したIDが存在するかを確認する
has1=$(autoTestHasKeyValue "$list_json" "businessUnitContactId" "$json1_id")
has2=$(autoTestHasKeyValue "$list_json" "businessUnitContactId" "$json2_id")
has3=$(autoTestHasKeyValue "$list_json" "businessUnitContactId" "$json3_id")
has4=$(autoTestHasKeyValue "$list_json" "businessUnitContactId" "$json4_id")
autoTestAssertIfEmptyString "$has1" "create1.jsonで作成した新規IDがリストに存在しませんでした"
autoTestAssertIfEmptyString "$has2" "create2.jsonで作成した新規IDがリストに存在しませんでした"
autoTestAssertIfEmptyString "$has3" "create3.jsonで作成した新規IDがリストに存在しませんでした"
autoTestAssertIfEmptyString "$has4" "create4.jsonで作成した新規IDがリストに存在しませんでした"

# Delete用の.jsonを作成する

echo "{\"business_unit_contact_id\": \"${json1_id}\" }" > get1.json
echo "{\"business_unit_contact_id\": \"${json2_id}\" }" > get2.json
echo "{\"business_unit_contact_id\": \"${json3_id}\" }" > get3.json
echo "{\"business_unit_contact_id\": \"${json4_id}\" }" > get4.json

# GETを実行してupdatedAtとdeletedAtのタイムスタンプを確認する
get1_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" get1.json "$host_info")
get2_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" get2.json "$host_info")
get3_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" get3.json "$host_info")
get4_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" get4.json "$host_info")

autoTestAssertIfEmptyString "$get1_json" "get1.jsonでのGETに失敗しました"
autoTestAssertIfEmptyString "$get2_json" "get2.jsonでのGETに失敗しました"
autoTestAssertIfEmptyString "$get3_json" "get3.jsonでのGETに失敗しました"
autoTestAssertIfEmptyString "$get4_json" "get4.jsonでのGETに失敗しました"

get1_updatedAt=$(autoTestGet "$get1_json" ".updatedAt")
get2_updatedAt=$(autoTestGet "$get2_json" ".updatedAt")
get3_updatedAt=$(autoTestGet "$get3_json" ".updatedAt")
get4_updatedAt=$(autoTestGet "$get4_json" ".updatedAt")

autoTestAssertIfEquals "$get1_updatedAt" "0" "get1.jsonで取得したレコードの更新時間が0になっています"
autoTestAssertIfEquals "$get2_updatedAt" "0" "get2.jsonで取得したレコードの更新時間が0になっています"
autoTestAssertIfEquals "$get3_updatedAt" "0" "get3.jsonで取得したレコードの更新時間が0になっています"
autoTestAssertIfEquals "$get4_updatedAt" "0" "get4.jsonで取得したレコードの更新時間が0になっています"

get1_deletedAt=$(autoTestGet "$get1_json" ".deletedAt")
get2_deletedAt=$(autoTestGet "$get2_json" ".deletedAt")
get3_deletedAt=$(autoTestGet "$get3_json" ".deletedAt")
get4_deletedAt=$(autoTestGet "$get4_json" ".deletedAt")

autoTestAssertIfNotEquals "$get1_deletedAt" "0" "get1.jsonで取得したレコードの削除時間が0以外になっています"
autoTestAssertIfNotEquals "$get2_deletedAt" "0" "get2.jsonで取得したレコードの削除時間が0以外になっています"
autoTestAssertIfNotEquals "$get3_deletedAt" "0" "get3.jsonで取得したレコードの削除時間が0以外になっています"
autoTestAssertIfNotEquals "$get4_deletedAt" "0" "get4.jsonで取得したレコードの削除時間が0以外になっています"


# company_idsでLISTを取得する

# business_unit_management_idsで


# 作成したレコードを削除する
echo "{\"business_unit_contact\": {\"business_unit_contact_id\": \"${json1_id}\", \"updated_at\": \"${get1_updatedAt}\" }}" > delete1.json
echo "{\"business_unit_contact\": {\"business_unit_contact_id\": \"${json2_id}\", \"updated_at\": \"${get2_updatedAt}\" }}" > delete2.json
echo "{\"business_unit_contact\": {\"business_unit_contact_id\": \"${json3_id}\", \"updated_at\": \"${get3_updatedAt}\" }}" > delete3.json
echo "{\"business_unit_contact\": {\"business_unit_contact_id\": \"${json4_id}\", \"updated_at\": \"${get4_updatedAt}\" }}" > delete4.json

autoTestExecGrpcurlDelete "$service" "$endpoint" delete1.json "$host_info" > /dev/null 2>&1
autoTestExecGrpcurlDelete "$service" "$endpoint" delete2.json "$host_info" > /dev/null 2>&1
autoTestExecGrpcurlDelete "$service" "$endpoint" delete3.json "$host_info" > /dev/null 2>&1
autoTestExecGrpcurlDelete "$service" "$endpoint" delete4.json "$host_info" > /dev/null 2>&1

# 削除後に再度GETを実行してdeletedAtのタイムスタンプを確認する
get1_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" get1.json "$host_info")
get2_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" get2.json "$host_info")
get3_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" get3.json "$host_info")
get4_json=$(autoTestExecGrpcurlGet "$service" "$endpoint" get4.json "$host_info")

autoTestAssertIfEmptyString "$get1_json" "get1.jsonでのGETに失敗しました"
autoTestAssertIfEmptyString "$get2_json" "get2.jsonでのGETに失敗しました"
autoTestAssertIfEmptyString "$get3_json" "get3.jsonでのGETに失敗しました"
autoTestAssertIfEmptyString "$get4_json" "get4.jsonでのGETに失敗しました"

get1_deletedAt=$(autoTestGet "$get1_json" ".deletedAt")
get2_deletedAt=$(autoTestGet "$get2_json" ".deletedAt")
get3_deletedAt=$(autoTestGet "$get3_json" ".deletedAt")
get4_deletedAt=$(autoTestGet "$get4_json" ".deletedAt")

autoTestAssertIfEquals "$get1_deletedAt" "0" "[削除後]get1.jsonで取得したレコードの削除時間が0になっています"
autoTestAssertIfEquals "$get2_deletedAt" "0" "[削除後]get2.jsonで取得したレコードの削除時間が0になっています"
autoTestAssertIfEquals "$get3_deletedAt" "0" "[削除後]get3.jsonで取得したレコードの削除時間が0になっています"
autoTestAssertIfEquals "$get4_deletedAt" "0" "[削除後]get4.jsonで取得したレコードの削除時間が0になっています"

# 削除後に再度LISTを実行して作成したIDの存在の有無とtotalを確認する
list_json=$(autoTestExecGrpcurlList "$service" "$endpoint" empty.json "$host_info")
autoTestAssertIfEmptyString "$list_json" "LISTに失敗しました"
total_after_delete=$(autoTestGet "$list_json" ".total")

echo "リストのtotal(DELETE後):"$total_after_delete

# 新規作成したIDがリストに存在しているか確認する
has1=$(autoTestHasKeyValue "$list_json" "businessUnitContactId" "$json1_id")
has2=$(autoTestHasKeyValue "$list_json" "businessUnitContactId" "$json2_id")
has3=$(autoTestHasKeyValue "$list_json" "businessUnitContactId" "$json3_id")
has4=$(autoTestHasKeyValue "$list_json" "businessUnitContactId" "$json4_id")

autoTestAssertIfNotEmptyString "$has1" "[削除後]create1.jsonで作成したレコードがリストにまだ存在しています"
autoTestAssertIfNotEmptyString "$has2" "[削除後]create2.jsonで作成したレコードがリストにまだ存在しています"
autoTestAssertIfNotEmptyString "$has3" "[削除後]create3.jsonで作成したレコードがリストにまだ存在しています"
autoTestAssertIfNotEmptyString "$has4" "[削除後]create4.jsonで作成したレコードがリストにまだ存在しています"

echo "PASSED BusinessUnitContact"