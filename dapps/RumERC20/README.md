## 安装 truffle

可以选择两种安装方式

##### 1.全局安装

```npm i -g truffle```

##### 2.项目内安装

```npm i truffle (-s)```

## 安装项目依赖

```npm i```

## 链接测试链

可以选着使用 truffle 自启测试链，或者链接其它暴露了 http 节点的链上(geth, ganache...)。

##### 1.使用 truffle 自启测试链

使用 ```turffle develop``` ，会启动本地测试链且同时进入truffle 的 console 界面 （js console），在该工具内可以直接使用 truffle 命令而不需要 truffle 前缀，比如 truffle compile 只需要输入 compile 即可，该工具集成了 web3 。

###### 注意：这种方式启动的链数据不会持久化，在退出 console 后，blockNumber 归零。

##### 2. 配置 truffle-config.js 中的 network 下的 develop 字段，通过 http-rpc 链接测试链。

配置好后，不需要执行 ```truffle devlop 命令```，在执行相应命令是会自动链接配置的测试链。此时可以通过执行```turffle console```进入 js console 。

## 编译

在 shell 使用 ```truffle compile``` 或者在 js console 里使用 ```compile``` 进行编译，编译后会生成 turffle 自己定义的 json 结构文件, 会放在 build/contracts/ 文件夹下 abi 和 bytecode 会被包含在内，额外的还会保留另外一些信息，比如部署了的合约地址，针对不同的链会保留多个地址。该文件信息会挂载在 js console 里，生成一个合约名的对象，通过其可以和已经部署的合约交互或者部署新的合约。

## 部署

在 shell 使用 ```truffle migrate```或者在 js console 里使用 migrate 进行部署(这两个地方使用 deploy 关键字和 migrate 一样的效果) ，执行该命令是也会进行编译检查，所以部署的时候可以跳过 compile 命令。

##### 版本管理

truffle 使用 Migrations 合约进行版本管理，该合约在 contracts 目录下，通过 truffle init 的项目会自动生成，同时会在 migrations 目录下生成一个 1_initial_migration.js 的脚本，用于初始化一个 Migrations 合约实例用于版本管理，之后每次要发布新的合约，需要添加对应的 js 脚本，命名规则为数字开头的 js 文件，而且数字需要大于上一次 migrate 的js文件开头数字。另外上一次发布开头数字的js文存需要存在，只要是上次开头的数字就行，文件名和文件内容都没要求，设计本义应该是不要删除 migrations 里的文件。

如果版本管理出现问题，可以在 migrate/deploy 命令后加上 --reset 参数。该参数通过发布一个新的 Migrations 合约,来重头开始进行版本管理。

另外，其实可以通过 js console 里的合约对象的 new() 方法来发布合约，绕过版本管理工具。但是这样发布的合约地址没有自动的存到之前说的 build/contracts 里对应的合约 json 文件里，这就需要自己保存地址，并且下次进入 js console 时使用 合约对象的 at 方法来挂载线上合约。这个方法也适合在 truffle 里，挂载通过其它方式发布的线上合约。

## 合约交互

##### 建立与合约绑定的合约实例

与合约交互前需要先拿到该合约的实例，在编译了合约后，在 js console 就可以获取该合约的合约对象，通过以下两种方法可以获得该合约的合约实例，以RumSC举例。

###### 1. 通过 truffle 部署的合约获取实例

```let instance = await RumSC.deployed()```

###### 2. 通过合约地址获取实例

``` let instance = await RumSC.at(合约地址) ```

##### 通过合约实例调用合约方法及获取 block 和 tx 信息

###### 1. transaction 调用

```let receipt = await instance.save("test", "0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51", "PIP:2001","test","test","0xfbd71db11e7d0038646252e19da21f68befd9db2d79dde02dded74088c2338aa","9ca7c049d6c7b5509951eec902f9145265e666008b15af59f3405295c2a07568569fb6f2235176e9ca8d4ba70eb94c04e656db379774b80a694681e2b0c0bd3300")```

block 和 transaction 信息通过该结果返回

###### 2.纯 call 调用

```let postLength = await instance.getLength()```
```postLength.toNumber()```

```let post = await instance.posts(0)```

该类调用只会返回执行的结果，不会发起 transation。

###### 3.强制调用

transaction 类型可以强制发起 call 调用，对等的 call 调用也能强制发起 transaction 调用。

```let receipt2 = await instance.post.call("test", "0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51", "PIP:2001","test","test","0xfbd71db11e7d0038646252e19da21f68befd9db2d79dde02dded74088c2338aa","9ca7c049d6c7b5509951eec902f9145265e666008b15af59f3405295c2a07568569fb6f2235176e9ca8d4ba70eb94c04e656db379774b80a694681e2b0c0bd3300")```

```let postLength2 = await instance.getLength.sendTransaction()```
d
需要注意的是强制调用不会返回预期结果。

## 测试
##### truffle 支持 .sol 及 .js 的测试脚本。在 test/ 中写好脚本后， 在 shell 使用 ```truffle test```或者在 js console 里使用 test 进行测试

## API

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
