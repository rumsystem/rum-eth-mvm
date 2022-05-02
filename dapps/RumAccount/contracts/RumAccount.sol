// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.9.0;

contract RumAccount {

  struct StringSet {
    string[] values;
    mapping(string => bool) has;
  }

  struct AddressSet {
    address[] values;
    mapping(address => bool) has;
  }

  struct Account {
    address user; // user_address
    string payment_provider;
    string payment_account;
    string meta;
    string memo;
  }

  modifier isOwner() {
    require(tx.origin == owner, "Caller is not owner");
    _;
  }

  modifier isManager() {
    require(managers[tx.origin], "Caller is not manager");
    _;
  }

  address public owner;
  mapping(address => bool) public managers;

  constructor() {
    owner = tx.origin;
    managers[tx.origin] = true;
  }

  function changeOwner(address newOwner) public isOwner {
    require(managers[newOwner], "newOwner need to be manager first.");
    owner = newOwner;
  }

  function addManager(address manager) public isOwner {
    managers[manager] = true;
  }

  function removeManager(address manager) public isOwner {
    require(manager != owner, "owner need to be changed first.");
    delete managers[manager];
  }

  mapping(address => mapping(string => Account)) public account;
  mapping(address => StringSet) private _accounts;
  mapping(string => mapping(string => address)) public userAddress;
  mapping(string => AddressSet) private _providerUsers;

  event Bind(address user, string indexed payment_provider, string payment_account, string meta, string memo);

  event UnBind(address user, string indexed payment_provider);

  function bind(address user, string memory payment_provider,string memory payment_account, string memory meta, string memory memo) public isManager {
    account[user][payment_provider] = Account({
      user: user,
      payment_provider: payment_provider,
      payment_account: payment_account,
      meta: meta,
      memo: memo
    }); 

    if (!_accounts[user].has[payment_provider]) {
      _accounts[user].values.push(payment_provider);
      _accounts[user].has[payment_provider] = true;
    }

    if (!_providerUsers[payment_provider].has[user]) {
      _providerUsers[payment_provider].values.push(user);
      _providerUsers[payment_provider].has[user] = true;
    }

    userAddress[payment_provider][payment_account] = user;

    emit Bind(user, payment_provider, payment_account, meta, memo);
  }

  function selfBind(string memory payment_provider,string memory payment_account, string memory meta, string memory memo) public {
    account[tx.origin][payment_provider] = Account({
      user: tx.origin,
      payment_provider: payment_provider,
      payment_account: payment_account,
      meta: meta,
      memo: memo
    }); 

    if (!_accounts[tx.origin].has[payment_provider]) {
      _accounts[tx.origin].values.push(payment_provider);
      _accounts[tx.origin].has[payment_provider] = true;
    }

    if (!_providerUsers[payment_provider].has[tx.origin]) {
      _providerUsers[payment_provider].values.push(tx.origin);
      _providerUsers[payment_provider].has[tx.origin] = true;
    }

    userAddress[payment_provider][payment_account] = tx.origin;

    emit Bind(tx.origin, payment_provider, payment_account, meta, memo);
  }

  function unBind(address user, string memory payment_provider) public isManager {
    delete userAddress[payment_provider][account[user][payment_provider].payment_account];
    delete account[user][payment_provider];

    if (_accounts[user].has[payment_provider]) {
      for(uint i = 0; i < _accounts[user].values.length; i++) {
        if (keccak256(abi.encodePacked(_accounts[user].values[i])) == keccak256(abi.encodePacked(payment_provider))) {
          _accounts[user].values[i] = _accounts[user].values[_accounts[user].values.length - 1];
          _accounts[user].values.pop();
          break;
        }
      }
      delete _accounts[user].has[payment_provider];
    }

    if (_providerUsers[payment_provider].has[user]) {
      for(uint i = 0; i < _providerUsers[payment_provider].values.length; i++) {
        if (keccak256(abi.encodePacked(_providerUsers[payment_provider].values[i])) == keccak256(abi.encodePacked(user))) {
          _providerUsers[payment_provider].values[i] = _providerUsers[payment_provider].values[_providerUsers[payment_provider].values.length - 1];
          _providerUsers[payment_provider].values.pop();
        }
      }
      delete _providerUsers[payment_provider].has[user];
    }

    emit UnBind(user, payment_provider);
  }

  function selfUnBind(string memory payment_provider) public {
    delete userAddress[payment_provider][account[tx.origin][payment_provider].payment_account];
    delete account[tx.origin][payment_provider];

    if (_accounts[tx.origin].has[payment_provider]) {
      for(uint i = 0; i < _accounts[tx.origin].values.length; i++) {
        if (keccak256(abi.encodePacked(_accounts[tx.origin].values[i])) == keccak256(abi.encodePacked(payment_provider))) {
          _accounts[tx.origin].values[i] = _accounts[tx.origin].values[_accounts[tx.origin].values.length - 1];
          _accounts[tx.origin].values.pop();
          break;
        }
      }
      delete _accounts[tx.origin].has[payment_provider];
    }

    if (_providerUsers[payment_provider].has[tx.origin]) {
      for(uint i = 0; i < _providerUsers[payment_provider].values.length; i++) {
        if (keccak256(abi.encodePacked(_providerUsers[payment_provider].values[i])) == keccak256(abi.encodePacked(tx.origin))) {
          _providerUsers[payment_provider].values[i] = _providerUsers[payment_provider].values[_providerUsers[payment_provider].values.length - 1];
          _providerUsers[payment_provider].values.pop();
          break;
        }
      }
      delete _providerUsers[payment_provider].has[tx.origin];
    }

    emit UnBind(tx.origin, payment_provider);
  }

  function accounts(address user) public view returns(Account[] memory) {
    Account[] memory res = new Account[](_accounts[user].values.length);
    for(uint i = 0; i < _accounts[user].values.length; i++) {
      res[i] = account[user][_accounts[user].values[i]];
    }
    return res;
  }

  function providerUsersCount(string memory payment_provider) public view returns(uint) {
    return  _providerUsers[payment_provider].values.length;
  }
}
