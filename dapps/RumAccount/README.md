### RumAccount

#### RumAccount
```0x03d0217c1e00E0A5eE3534Ea88D0108bF872bAD1```

#### 实例方法

##### changeOwner(address newOwner)
改变合约所有者

##### addManager(address manager)
添加合约管理员

##### removeManager(address manager)
删除合约管理员

##### bind(address user, string payment_provider, string payment_account, string meta, string memo)
绑定账户支付信息

##### selfBind(string payment_provider, string payment_account, string meta, string memo)
绑定当前使用账户支付信息

##### unBind(address user, string payment_provider)
解绑账户特定支付商的支付信息

##### selfUnBind(string payment_provider)
解绑当前使用账户特定支付商的支付信息

##### account(address user, string payment_provider)
获取用户特定支付提供方账户

##### accounts(address user)
获取用户所有支付账户

##### userAddress(string payment_provider, string payment_account)
获取绑定过该支付账户的最新用户的地址

##### providerUsersCount(string payment_provider)
获取绑定过该支付商的用户数

#### 事件

##### Bind(address user, string indexed payment_provider, string payment_account, string meta, string memo)
绑定账户事件

##### UnBind(address user, string indexed payment_provider)
解绑账户事件
