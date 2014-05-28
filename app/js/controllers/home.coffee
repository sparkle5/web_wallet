angular.module("app").controller "HomeController", ($scope, $modal, $log, RpcService, Wallet) ->
  $scope.transactions = []
  $scope.balance_amount = 0.0
  $scope.balance_asset_type = ''

  watch_for = ->
    Wallet.info

  on_update = (info) ->
    $scope.balance_amount = info.balance if info.wallet_open

  $scope.$watch(watch_for, on_update, true)


  fromat_address = (addr) ->
    return "-" if !addr or addr.length == 0
    res = ""
    angular.forEach addr, (a) ->
      res += ", " if res.length > 0
      res += a[1]
    res
  format_amount = (delta_balance) ->
    return "-" if !delta_balance or delta_balance.length == 0
    first_asset = delta_balance[0]
    return "-" if !first_asset or first_asset.length < 2
    first_asset[1]

  # TODO: move transactions loading into Angular's service,
  # it should be able to cache transactions and update the cache when updates detected
  # also it should sort transactions by trx_num desc
  load_transactions = ->
    RpcService.request("wallet_get_transaction_history").then (response) ->
      $scope.transactions.splice(0, $scope.transactions.length)
      count = 0
      angular.forEach response.result, (val) ->
        count += 1
        if count < 10
          $scope.transactions.push
            block_num: val.block_num
            trx_num: val.trx_num
            time: val.confirm_time
            amount: format_amount(val.delta_balance)
            from: fromat_address(val.from)
            to: fromat_address(val.to)
            memo: val.memo

  Wallet.get_balance().then (balance)->
    $scope.balance_amount = balance.amount
    $scope.balance_asset_type = balance.asset_type
    load_transactions()