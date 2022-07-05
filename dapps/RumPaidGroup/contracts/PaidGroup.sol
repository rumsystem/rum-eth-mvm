// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// import "hardhat/console.sol";
import { RumERC20 } from "./RumERC20.sol";

contract PaidGroup {
  // 保存Dapp的基本信息
  struct DappInfo {
    string name;
    string version;
    string developer;         // 开发者 或 开发团队的名称
    address payable receiver; // owner收款的 eth address
    address payable deployer; // owner部署的 eth address
    uint256 invokeFee;         // 调用 mvm invoke 为 group owner 做 announce group amount 时收取的费用
    uint64 shareRatio;        // group owner share ratio，比如：80 代表 group owner 会分走 80%
  }
  DappInfo private dappInfo;

  // 保存付费群组的价格
  struct Price {
    address payable owner; // group owner eth address
    address tokenAddr;      // token contract address
    uint256 amount;         // token amount
    uint64 duration;       // 付费后的有效期
  }

  // 保存所有付费群的信息
  mapping(uint128 => Price) priceList;   // groupId => Price

  // 支付会员
  struct Member {
    uint128 groupId;
    uint256 amount;
    address tokenAddr;
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

  bool private initialized;


  // This modifier prevents a function from being called while
  // it is still executing.
  modifier noReentrancy() {
    require(!locked, "No reentrancy");

    locked = true;
    _;
    locked = false;
  }

  modifier ownerOnly() {
    require(msg.sender == dappInfo.deployer, "owner only");
    _;
  }

  function initialize(string memory _version, uint256 _invokeFee,  uint64 _shareRatio) public {
    // console.log("initialize PaidGroup ...");
    require(!initialized, "Contract instance has already been initialized");
    initialized = true;

    require(_invokeFee > 0, "invalid invoke fee");
    require(_shareRatio > 0 && _shareRatio <= 100, "invalid share ratio");

    dappInfo = DappInfo({
      name: "Paid Group",
      version: _version,
      developer: "Quorum Team",
      receiver: payable(address(0xF0E75E53f0AEC66E9536c7D9c7afCDB140aCDE19)),  // 平台收款地址
      deployer: payable(msg.sender),
      invokeFee: _invokeFee,
      shareRatio: _shareRatio
    });
  }

  // 判断两个 string 是否相等
  function isEqualString(string memory a, string memory b) public pure returns (bool) {
    if(bytes(a).length != bytes(b).length) {
      return false;
    }
    return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
  }

  function updateDappInfo(string memory _version, uint256 _invokeFee, uint64 _shareRatio) public ownerOnly {
    require(_invokeFee > 0, "invalid invoke fee");
    require(_shareRatio > 0 && _shareRatio <= 100, "invalid share ratio");

    if (bytes(_version).length != 0) {
      dappInfo.version = _version;
    }
    if (_invokeFee > 0) {
      dappInfo.invokeFee = _invokeFee;
    }
    if (_shareRatio > 0) {
      dappInfo.shareRatio = _shareRatio;
    }
  }

  function getDappInfo() public view returns (DappInfo memory) {
    return dappInfo;
  }

  function getBalance() public view ownerOnly returns (uint) {
    return address(this).balance;
  }

  // get the price detail of paid group
  function getPrice(uint128 _groupId) public view returns (Price memory) {
    Price memory item = priceList[_groupId];
    return item;
  }

  // add the price of paid group
  function addPrice(uint128 _groupId, uint64 _duration, address _tokenAddr, uint256 _amount) payable public noReentrancy {
    // console.log("addPrice, groupId: %s duration: %d tokenType: %s amount: %d ...", _groupId, _duration, _tokenAddr, _amount);

    require(msg.value == dappInfo.invokeFee, "invalid invoke fee");
    require(_groupId > 0, "invalid group id");
    require(_duration > 0, "invalid duration");
    require(_amount > 0, "invalid token amount");
    require(_tokenAddr != address(0), "invalid token contract address");
    require(priceList[_groupId].owner == address(0), "group amount already announced");

    Price memory item = Price({
      owner: payable(msg.sender),
      amount: _amount,
      tokenAddr: _tokenAddr,
      duration: _duration
    });

    priceList[_groupId] = item;

    dappInfo.receiver.transfer(msg.value);

    emit AnnouncePrice(_groupId, item);
  }

  // update the amount of paid group
  function updatePrice(uint128 _groupId, uint64 _duration, address _tokenAddr, uint256 _amount) payable public noReentrancy {
    // console.log("updatePrice, groupId: %s duration: %d tokenType: %s amount: %d ...", _groupId, _duration, _tokenAddr, _amount);
    require(msg.value == dappInfo.invokeFee, "invalid invoke fee");
    require(_groupId > 0, "invalid group id");
    require(_tokenAddr != address(0), "invalid token contract address");
    address user = payable(msg.sender);
    Price storage item = priceList[_groupId];

    require(item.owner == user, "only group owner can update amount");

    if (_amount > 0) {
      item.amount = _amount;
      item.tokenAddr = _tokenAddr;
    }
    if (_duration > 0) {
      item.duration = _duration;
    }

    dappInfo.receiver.transfer(msg.value);

    if (_amount > 0 || _duration > 0) {
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
    // console.log("isPaid, user: %s groupId: %s ...", user, groupId);

    bytes memory key = getMemberKey(user, groupId);
    Member memory m = memberList[key];

    if (m.expiredAt > block.timestamp) {
      return true;
    }

    return false;
  }

  function pay(uint128 groupId) payable public noReentrancy {
    Price storage item = priceList[groupId];

    require(item.amount > 0, "can not find group price");
    require(item.tokenAddr != address(0), "invalid token contract address");

    address payable user = payable(msg.sender);

    // 检查 user 成员，看看是不是已经付费了？
    require(!isPaid(user, groupId), "already paid");

    require(RumERC20(item.tokenAddr).allowance(user, address(this)) >= item.amount, "please approve token allowance");
    RumERC20(item.tokenAddr).transferFrom(user, address(this), item.amount);

    // 更新 memberList
    Member memory member = Member({
      groupId: groupId,
      tokenAddr: item.tokenAddr,
      amount: item.amount,
      expiredAt: block.timestamp + item.duration
    });

    bytes memory key = getMemberKey(user, groupId);
    memberList[key] = member;

    // 将钱分给group owner 和 平台
    uint256 ownerAmount = item.amount * dappInfo.shareRatio / 100;
    RumERC20(item.tokenAddr).transfer(item.owner, ownerAmount);
    RumERC20(item.tokenAddr).transfer(dappInfo.receiver, item.amount - ownerAmount);

    emit AlreadyPaid(user, member);
  }

  // Function to receive Ether. msg.data must be empty
  receive() external payable {}

  // Fallback function is called when msg.data is not empty
  fallback() external payable {}
}
