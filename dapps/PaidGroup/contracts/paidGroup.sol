// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {BytesLib} from './bytes.sol';
import {MixinProcess} from './mixin.sol';

contract PaidGroup is MixinProcess {
    using BytesLib for bytes;

    // 保存付费群组的价格
    struct Price {
        bytes mixinReceiver;             // group owner mixin receiver address; value is event.members
        uint64 price;
        bool isLifeMember;       // 终生会员
        uint64 duration;         // 付费后的有效期
        // uint numberOfMembers;  // 会员数量
    }

    // 保存所有付费群的信息
    mapping(uint128 => Price) priceList;   // groupId => Price

    // 支付会员
    struct Member {
        uint128 groupId;
        uint64 price;
        bool isLifeMember;  // 终生会员
        uint256 expiredAt;     // 过期时间；如果 isLifeMember != true，expiredAt = duration + paidAt，expiredAt > now 决定没有过期
    }

    enum Action {
        AnnounceGroupPrice,
        PayForGroup
    }

    // Extra 自定义的 extra 结构
    // action
    // 0 - announce group price; params: groupId, amount
    // 1 - pay; params: groupId, amount
    struct Extra {
        Action action;       // uint8
        uint128 groupId;
        address rumAddress;  // quorum address, 20 bytes
        uint64 amount;       // group price or paid amount
        uint64 duration;     // paid group expire duration, 2 ** 32 / (60 * 60 * 24 * 365) = 136.19 年
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

    // xxxx record extra
    Extra[] public extra_logs;
    Event[] public event_logs;
    string[] public extra_str_logs;
    bytes[] public extra_bytes_logs;

    function getExtraStrLogs(uint i) public view returns (string memory) {
        return extra_str_logs[i];
    }

    function getExtraBytesLogs(uint i) public view returns (bytes memory) {
        return extra_bytes_logs[i];
    }

    function getExtraLogs(uint i) public view returns (Extra memory) {
        return extra_logs[i];
    }

    function getEventLogs(uint i) public view returns (Event memory) {
        return event_logs[i];
    }

    // PID is a UUID of Mixin Messenger user, e.g. 27d0c319-a4e3-38b4-93ff-cb45da8adbe1
    uint128 public constant PID = 0xfd5a9224799b374da0524f1c7b1b8c8c;

    function _pid() internal pure override(MixinProcess) returns (uint128) {
      return PID;
    }

    // entry
    function _work(Event memory evt) internal override(MixinProcess) returns (bool) {
      require(evt.timestamp > 0, "invalid timestamp");
      // require(evt.nonce % 2 == 1, "not an odd nonce");
      // string memory extra_str = string(abi.encodePacked(evt.extra));
      // extra_str_logs.push(extra_str);
      // bytes memory extra = fromHex(extra_str);
      event_logs.push(evt);
      extra_bytes_logs.push(evt.extra);
      
      Extra memory ext = _parse_extra(evt.extra);
      // xxxxx
      extra_logs.push(ext);


      require(ext.groupId > 0, "invalid group id");
      // check eth address

      if (ext.action == Action.AnnounceGroupPrice) {
        require(ext.duration > 0, "invalid paid group duration");
        require(ext.amount > 0, "invalid paid group price");

        addPrice(ext.groupId, evt.members, false, ext.duration, ext.amount);
      } else if (ext.action == Action.PayForGroup) {
        if (! isPaid(ext.rumAddress, ext.groupId)) {
          pay(ext.rumAddress, ext.groupId);
          // send 0.8 * evt.amount to group owner
          Price memory price = priceList[ext.groupId];
          bytes memory mixinReceiver = price.mixinReceiver;
          uint256 amount = evt.amount * 8 / 10;

          require(price.price == evt.amount, "invalid paid group price");  // 确保单位一致

          bytes memory log = buildMixinTransaction(evt.nonce, evt.asset, amount, "paid group", mixinReceiver);
          emit MixinTransaction(log);
        }
      } else {
          revert("un-support action");
      }

      return true;
    }

    // convert bytes to eth address
    function bytesToAddress(bytes memory b) private pure returns (address addr) {
      assembly {
        addr := mload(add(b, 20))
      }
      return addr;
    }

    // parse extra
    function _parse_extra(bytes memory extra) public pure returns (Extra memory) {
        Extra memory ext;
        uint128 offset = 0;

        uint8 action = extra.toUint8(offset);
        offset += 1;
        if (action == 0) {
            ext.action = Action.AnnounceGroupPrice;
        } else if (action == 1) {
            ext.action = Action.PayForGroup;
        }

        ext.groupId = extra.toUint128(offset);
        offset += 16;

        ext.rumAddress = bytesToAddress(extra.slice(offset, 20));
        offset += 20;

        ext.amount  = extra.toUint64(offset);
        offset += 8;

        ext.duration = extra.toUint32(offset);
        offset += 4;

        return ext;
    }

    // Convert an hexadecimal character to their value
    function fromHexChar(uint8 c) public pure returns (uint8) {
        uint8 val;
        if (bytes1(c) >= bytes1('0') && bytes1(c) <= bytes1('9')) {
            val = c - uint8(bytes1('0'));
        } else if (bytes1(c) >= bytes1('a') && bytes1(c) <= bytes1('f')) {
            val = 10 + c - uint8(bytes1('a'));
        } else if (bytes1(c) >= bytes1('A') && bytes1(c) <= bytes1('F')) {
            val = 10 + c - uint8(bytes1('A'));
        }

        return val;
    }

    // Convert an hexadecimal string to raw bytes
    function fromHex(string memory s) public pure returns (bytes memory) {
        bytes memory ss = bytes(s);
        require(ss.length%2 == 0); // length must be even
        bytes memory r = new bytes(ss.length/2);
        for (uint i=0; i<ss.length/2; ++i) {
            r[i] = bytes1(fromHexChar(uint8(ss[2*i])) * 16 +
                        fromHexChar(uint8(ss[2*i+1])));
        }
        return r;
    }

    // This modifier prevents a function from being called while
    // it is still executing.
    modifier noReentrancy() {
        require(!locked, "No reentrancy");

        locked = true;
        _;
        locked = false;
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
    function addPrice(uint128 _groupId, bytes memory receiver, bool _isLifeMember, uint64 _duration, uint64 _price) public {
        Price memory item = Price({
            mixinReceiver: receiver,
            price: _price,
            isLifeMember: false,
            duration: _duration
        });
        if (_isLifeMember) {
            item.isLifeMember = true;
            item.duration = 0;
        } else {
            item.isLifeMember = false;
            item.duration = _duration;
        }

        priceList[_groupId] = item;

        emit AnnouncePrice(_groupId, item);
    }

    // update the price of paid group
    function updatePrice(uint128 _groupId, bool _isLifeMember, uint64 _duration, uint64 _price) public {
        Price storage item = priceList[_groupId];

        item.price = _price;
        if (_isLifeMember) {
            item.isLifeMember = _isLifeMember;
        } else {
            item.duration = _duration;
        }

        emit UpdatePrice(_groupId, item);
    }

    // uint to bytes
    function toBytes(uint256 x) public pure returns (bytes memory b) {
      b = new bytes(32);
      assembly { mstore(add(b, 32), x) }
    }

    // generate the key of memberList
    function getMemberKey(address addr, uint128 groupId) public pure returns (bytes memory) {
        return bytes.concat(abi.encodePacked(addr), '@', toBytes(groupId));
    }

    // check if the two string is equal
    function stringEqual(string memory a, string memory b) public pure returns (bool) {
        if (keccak256(bytes(a)) == keccak256(bytes(b))) {
            return true;
        }

        return false;
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

        if (m.isLifeMember || m.expiredAt > block.timestamp) {
            return true;
        }

        return false;
    }

    // paid group member，实际的支付会在mixin中完成
    // user 应该是 msg.sender，但这个接口由 mvm 调用；所以，作为参数让 mvm 传入
    function pay(address user, uint128 groupId) public {
        Price storage item = priceList[groupId];

        require(item.price > 0, "can not find group price");

        bytes memory key = getMemberKey(user, groupId);

        // 检查 user 成员，看看是不是已经付费了？
        if (isPaid(user, groupId)) {
            return;
        }

        // 更新 memberList
        Member memory member = Member({
            groupId: groupId,
            price: item.price,
            isLifeMember: false,
            expiredAt: 0
        });
        if (item.isLifeMember) {
            member.isLifeMember = true;
        } else {
            member.expiredAt = block.timestamp + item.duration;
        }

        memberList[key] = member;

        emit AlreadyPaid(user, member);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
