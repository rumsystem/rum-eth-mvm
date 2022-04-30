
### RumERC20


#### 部署合约

##### construct(string tokenName,string tokensymbol,uint256 cap,address minter)
不可直接调用，部署该合约时调用一次。需传入4个参数,token 名，token 符号(单位),初始化的token数不使用额外挖矿算法的情况下亦即所有的token数，初始化token 的接受地址。

#### 实例方法

##### totalSupply()
返回发行 token 总数

##### balanceOf(address account)
返回某地址拥有的 token 总数

##### transfer(address recipient, uint256 amount)
将调用地址(可以是合约地址)下的token 转到接收地址下

##### allowance(address owner, address spender)
查询 owner 地址授权给 spender 地址可转账的 token 数

##### approve(address spender, uint256 amount)
调用地址授权给 spender 地址, 可用于转账的 token 数量为 amount

##### transferFrom(address sender, address recipient, uint256 amount)
调用地址在 sender 地址授权给其的转账额度内对 sender 地址内的 token 进行转账操作

##### rumTransfer(address recipient, uint256 amount, string uuid)
将调用地址(可以是合约地址)下的 token 转到接收地址下, 需要附上未使用过的 uuid

##### rumApprove(address spender, uint256 amount, string uuid)
调用地址授权给 spender 地址, 可用于转账的 token 数量为 amount, 需要附上未使用过的 uuid

##### rumTransferFrom(address sender, address recipient, uint256 amount, string uuid)
调用地址在 sender 地址授权给其的转账额度内对 sender 地址内的 token 进行转账操作, 需要附上未使用过的 uuid

##### name()
获取 token 名称，非 ERC20 标准方法

##### symbol()
获取 token 单位，非 ERC20 标准方法

##### decimal()
获取 token 的小数位，也是最小计量单位，由于 solidity 不支持浮点数，因而通过 decimal 来表征数值的实际位数，比如 token 的单位是 T，decimal 是 2, 那么 100 个 token 就相当于 1T。eth 的最小单位正是 10**-18 eth 也就是 1 wei,这里固定的也是18.非 ERC20 标准方法

#### 事件

##### Transfer(address indexed from, address indexed to, uint256 value);
转账事件

##### Approval(address indexed owner, address indexed spender, uint256 value);
授权事件
