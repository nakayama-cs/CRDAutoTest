serviceName=$1
endpoint=$2
create_proto_param_nm=$3
get_proto_param_nm=$4
id_name_on_json=$5

# 定数値
HOST_INFO="http://localhost:8000"

# パラメータチェック1
if [ -z "$serviceName" ]; then
  echo "サービス名が未指定です。\n例) mtechnavi.api.company.BusinessUnitManagementService"
  exit 1
fi

# パラメータチェック2
if [ -z "$endpoint" ]; then
  echo "エンドポイントが未指定です。\n例) BusinessUnitContactHeader"
  exit 1
fi

# パラメータチェック3
if [ -z "$create_proto_param_nm" ]; then
  echo "CREATEのproto名が未指定です。\n例) business_unit_contact_header"
  exit 1
fi

# パラメータチェック4
if [ -z "$get_proto_param_nm" ]; then
  echo "GETのproto名が未指定です。\n例) business_unit_contact_header_id"
  exit 1
fi

# パラメータチェック5
if [ -z "$id_name_on_json" ]; then
  echo ".jsonでのIDのキー名が未指定です。\n例) businessUnitContactHeaderId"
  exit 1
fi

echo "サービス: "$serviceName
echo "エンドポイント: "$endpoint

# 空の.json作成
echo "{}" > empty.json
# create.jsonの作成
echo "{\"${create_proto_param_nm}\": {\"company_id\": \"1\"}}" > create.json

# 最初に現在のリストを取得する
list_result_before=$(go run ./cmd/mtechnavi-cli/ grpcurl ${serviceName}/List${endpoint}s @empty.json -u ${HOST_INFO} -s)
if [ -z "$list_result_before" ]; then
  echo "NG: リストの取得に失敗しました"
  exit 1
fi

total_before=$(echo "$list_result_before" | sed -n 's/.*"total":\s*"\(.*\)".*/\1/p')

echo "現在のトータルカウント: "$total_before

# データ作成
create_result=$(go run ./cmd/mtechnavi-cli/ grpcurl ${serviceName}/Create${endpoint} @create.json -u ${HOST_INFO} -s)
if [ -z "$create_result" ]; then
  echo "NG: 新規IDの作成に失敗しました"
  exit 1
fi

new_id=$(echo "$create_result" | sed -n "s/.*\"${id_name_on_json}\":\s*\"\(.*\)\".*/\1/p")

echo "新規作成したID: "$new_id

# リストのトータルカウントが増えていることを確認
list_result_after=`go run ./cmd/mtechnavi-cli/ grpcurl ${serviceName}/List${endpoint}s @empty.json -u ${HOST_INFO} -s`
if [ -z "$list_result_after" ]; then
  echo "NG: リストの取得に失敗しました"
  exit 1
fi

total_after=$(echo "$list_result_after" | sed -n 's/.*"total":\s*"\(.*\)".*/\1/p')

echo "作成後のトータルカウント: "$total_after

# トータルカウントが１インクリメントされていることを確認
if [ "$((total_before + 1))" -ne "$total_after" ]; then
  echo "NG: トータルカウントが不正です"
  exit 1
else
  echo "OK: トータルカウントのインクリメント"
fi

# 作成したIDが作成前のリストに存在しないことを確認する
if echo "$list_result_before" | grep -q "$new_id"; then
  echo "NG: 作成したIDが作成前のリストに存在しました: "$new_id
  exit 1
else
  echo "OK: 新規ID発行"
fi

# 作成したIDがリスト内で出現していることを確認する
if ! echo "$list_result_after" | grep -q "$new_id"; then
  echo "NG: 作成したIDがリスト内に出現しませんでした: "$new_id
  exit 1
else
  echo "OK: 新規IDのリスト取得"
fi

# get.jsonの作成
echo "{\"${get_proto_param_nm}\": \"${new_id}\"}" > get.json

# 作成したIDがGETで取得できることを確認する
get_result=$(go run ./cmd/mtechnavi-cli/ grpcurl ${serviceName}/Get${endpoint} @get.json -u ${HOST_INFO} -s)

# GETで取得したID
got_id=$(echo "$get_result" | sed -n "s/.*\"${id_name_on_json}\":\s*\"\(.*\)\".*/\1/p")
# 更新時間
update_at=$(echo "$get_result" | sed -nE 's/.*"updatedAt": "([^"]*)".*/\1/p' | tail -n 1)
# 削除時間
delete_at=$(echo "$get_result" | sed -nE 's/.*"deletedAt": "([^"]*)".*/\1/p' | tail -n 1)

echo "取得したID:"$got_id

# 新規作成したIDが返却されていることを確認
if [ "$got_id" != "$new_id" ]; then
  echo "NG: 作成したIDがGETで取得できませんでした"
  exit 1
else
  echo "OK: GETでの作成済みIDの取得"
fi

# 更新時間が0以外であることを確認
if [ "$update_at" = "0" ]; then
  echo "NG: 作成直後のGETで取得したレコードの更新時間が0になっています"
  exit 1
else
  echo "OK: 作成直後の更新時間"
fi

# 削除時間が0以外であることを確認
if [ "$delete_at" != "0" ]; then
  echo "NG: 作成直後のGETで取得したレコードの削除時間が0以外になっています"
  exit 1
else
  echo "OK: 作成直後の削除時間"
fi

# delete.jsonの作成
echo "{\"${create_proto_param_nm}\": {\"${get_proto_param_nm}\": \"${new_id}\", \"updated_at\": ${update_at}}}" > delete.json

# 新規IDの削除
go run ./cmd/mtechnavi-cli/ grpcurl ${serviceName}/Delete${endpoint} @delete.json -u ${HOST_INFO} -s > /dev/null 2>&1

# 削除後に再GETする
get_result=$(go run ./cmd/mtechnavi-cli/ grpcurl ${serviceName}/Get${endpoint} @get.json -u ${HOST_INFO} -s)

# GETで取得したID
got_id=$(echo "$get_result" | sed -n "s/.*\"${id_name_on_json}\":\s*\"\(.*\)\".*/\1/p")
# 削除時間
delete_at=$(echo "$get_result" | sed -n "s/.*\"deletedAt\":\s*\"\(.*\)\".*/\1/p")

echo "削除後に取得したID:"$got_id
echo "削除後の削除時間:"$delete_at

# 削除時間が0以外であることを確認
if [ "$delete_at" = "0" ]; then
  echo "NG: 削除直後のGETで取得したレコードの削除時間が0になっています"
  exit 1
else
  echo "OK: 削除直後の削除時間"
fi

# 現在のリストを取得する
list_result_after_delete=$(go run ./cmd/mtechnavi-cli/ grpcurl ${serviceName}/List${endpoint}s @empty.json -u ${HOST_INFO} -s)
if [ -z "$list_result_after_delete" ]; then
  echo "NG: リストの取得に失敗しました"
  exit 1
fi
total_after_delete=$(echo "$list_result_after_delete" | sed -n 's/.*"total":\s*"\(.*\)".*/\1/p')
echo "削除後のリスト数:"$total_after_delete

# 削除後のトータル
if [ $total_before != $total_after_delete ]; then
  echo "NG: 削除後のリスト数が作成前の数と同じになっていません"
  exit 1
else
  echo "OK: 削除後のリストのトータル"
fi

# 作成したIDが作成前のリストに存在しないことを確認する
if echo "$list_result_after_delete" | grep -q "$new_id"; then
  echo "NG: 作成したIDが削除後のリストに存在しました: "$new_id
  exit 1
else
  echo "OK: 削除後のリストからのID削除"
fi

echo "テスト完了"
