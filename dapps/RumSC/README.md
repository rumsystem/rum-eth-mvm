### RumSC

#### Address
```0x13521ED10784455994B63E47329bc55cc005afbB```

#### 实例方法

##### save(string id, string user_address, string protocaol, string meta, string data, string hash, string signature)
保存一个内容到合约

##### getLength()
获取合约内容总数

##### posts(uint index)
获取具体一个内容

#### 事件

##### NewPost(string id, string user_address, string indexed protocaol, string meta, string data, string hash, string signature)
新内容保存事件
