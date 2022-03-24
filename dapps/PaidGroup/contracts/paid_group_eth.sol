// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract PaidGroup {
  // 保存Dapp的基本信息
  struct DappInfo {
    string name;
    string version;
    string developer;      // 开发者 或 开发团队的名称
    address payable owner; // owner 的 eth address
    uint64 invokeFee;      // 调用 mvm invoke 为 group owner 做 announce group price 时收取的费用
    uint64 shareRatio;     // group owner share ratio，比如：80 代表 group owner 会分走 80%
  }
  DappInfo private dappInfo;

  // 保存付费群组的价格
  struct Price {
    address payable owner; // group owner eth address
    uint64 price;
    uint64 duration;       // 付费后的有效期
  }

  // 保存所有付费群的信息
  mapping(uint128 => Price) priceList;   // groupId => Price

  // 支付会员
  struct Member {
    uint128 groupId;
    uint64 price;
    uint256 expiredAt; // 过期时间；expiredAt = duration + paidAt，expiredAt > now 决定没有过期
  }

  // 群付费的会员
  mapping(bytes => Member) public memberList; // key: user address@groupId

  bool private locked;

  // 公布付费群的事件
  event AnnouncePrice(uint128 indexed groupId, Price price);
  // 修改付费群的事件
  event UpdatePrice(uint128 indexed groupId, Price price);
  // 完成支付的事件
  event AlreadyPaid(address indexed user, Member member);

  constructor () {
    dappInfo = DappInfo({
      name: "Paid Group",
      version: "0.0.1",
      developer: "Quorum Team",
      owner: payable(msg.sender),  // 平台收款地址
      invokeFee: 1 * 1e8,
      shareRatio: 80
    });
    require(dappInfo.shareRatio > 0 && dappInfo.shareRatio <= 100, "invalid share ratio");
  }

  // This modifier prevents a function from being called while
  // it is still executing.
  modifier noReentrancy() {
    require(!locked, "No reentrancy");

    locked = true;
    _;
    locked = false;
  }

  modifier ownerOnly() {
    require(msg.sender == dappInfo.owner, "owner only");
    _;
  }

  function getDappInfo() public view returns (DappInfo memory) {
    return dappInfo;
  }

  function getBalance() public view ownerOnly returns (uint) {
    return address(this).balance;
  }

  // get the price of paid group
  function getPrice(uint128 _groupId) public view returns (uint64) {
    Price memory item = priceList[_groupId];
    return item.price;
  }

  // get the price detail of paid group
  function getPriceDetail(uint128 _groupId) public view returns (Price memory) {
    Price memory item = priceList[_groupId];
    return item;
  }

  // add the price of paid group
  function addPrice(uint128 _groupId, uint64 _duration, uint64 _price) payable public noReentrancy {
    require(msg.value == dappInfo.invokeFee, "invalid invoke fee");
    require(_groupId > 0, "invalid group id");
    require(_price > 0, "invalid price");
    require(_duration > 0, "invalid duration");
    require(priceList[_groupId].owner == address(0), "group price already announced");

    Price memory item = Price({
      owner: payable(msg.sender),
      price: _price,
      duration: _duration
    });

    priceList[_groupId] = item;

    dappInfo.owner.transfer(msg.value);

    emit AnnouncePrice(_groupId, item);
  }

  // update the price of paid group
  function updatePrice(uint128 _groupId, uint64 _duration, uint64 _price) payable public noReentrancy {
    require(msg.value == dappInfo.invokeFee, "invalid invoke fee");
    require(_groupId > 0, "invalid group id");
    address user = payable(msg.sender);
    Price storage item = priceList[_groupId];

    require(item.owner == user, "only group owner can update price");

    if (_price > 0) {
      item.price = _price;
    }
    if (_duration > 0) {
      item.duration = _duration;
    }

    dappInfo.owner.transfer(msg.value);

    if (_price > 0 || _duration > 0) {
      emit UpdatePrice(_groupId, item);
    }
  }

  // uint to bytes
  function toBytes(uint256 x) public pure returns (bytes memory b) {
    b = new bytes(32);
    assembly { mstore(add(b, 32), x) }
  }

  // generate the key of memberList
  function getMemberKey(address user, uint128 groupId) public pure returns (bytes memory) {
    return bytes.concat(abi.encodePacked(user), '@', toBytes(groupId));
  }

  // get paid detail
  function getPaidDetail(address user, uint128 groupId) public view returns (Member memory) {
    bytes memory key = getMemberKey(user, groupId);
    Member memory m = memberList[key];

    return m;
  }

  // check if the user is a paid group member
  // user is the eth address of the quorum user
  function isPaid(address user, uint128 groupId) public view returns (bool) {
    bytes memory key = getMemberKey(user, groupId);
    Member memory m = memberList[key];

    if (m.expiredAt > block.timestamp) {
      return true;
    }

    return false;
  }

  function pay(uint128 groupId) payable public noReentrancy {
    Price storage item = priceList[groupId];

    require(item.price > 0, "can not find group price");
    require(item.price == msg.value, "invalid pay price");

    address payable user = payable(msg.sender);

    // 检查 user 成员，看看是不是已经付费了？
    require(!isPaid(user, groupId), "already paid");

    // 更新 memberList
    Member memory member = Member({
      groupId: groupId,
      price: item.price,
      expiredAt: block.timestamp + item.duration
    });

    bytes memory key = getMemberKey(user, groupId);
    memberList[key] = member;

    // 将钱分给group owner 和 平台
    uint256 amount = msg.value * dappInfo.shareRatio / 100;
    item.owner.transfer(amount);
    dappInfo.owner.transfer(msg.value - amount);

    emit AlreadyPaid(user, member);
  }

  // Function to receive Ether. msg.data must be empty
  receive() external payable {}

  // Fallback function is called when msg.data is not empty
  fallback() external payable {}
}
