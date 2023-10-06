#!/bin/bash

# 共通関数をインポートする
source ./auto_test_lib.sh

# 自動テスト実行のための環境が構築されていない場合はこの行でアサートする
autoTestAssertIfNotSupported

# パラメータ
service="mtechnavi.api.company.BusinessUnitManagementService"
endpoint="TokyoShokoResearch"
json_file="empty.json"
host_info="http://localhost:8000"

# Listxxxxsの呼び出し
json=$(autoTestExecGrpcurlList "$service" "$endpoint" "$json_file" "$host_info")

# jsonの取得に失敗した場合はこの行でアサートする
autoTestAssertIfEmptyString "$json" "リストの取得に失敗しました"

# jsonの中の先頭から"deletedAt"キーを探して、最初に見つかったキーの値を返却する
echo "first: "$(autoTestGetFirst "$json" "deleteAt")

# jsonの中の後方から"deletedAt"キーを探して、最初に見つかったキーの値を返却する
echo "last : "$(autoTestGetLast "$json" "deletedAt")
