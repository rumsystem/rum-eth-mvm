// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.4 <0.9.0;

interface IERC20 {
  function balanceOf(address who) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract RumBridge {
  address public rumERC20Addr;

  constructor(address _rumERC20Addr) payable{
    rumERC20Addr = _rumERC20Addr;
  }

  function getEtherBalance() view public returns(uint256) {
    return address(this).balance;
  }

  function getRumERC20Balance() view public returns (uint256) {
    return IERC20(rumERC20Addr).balanceOf(address(this));
  }

  // 从mixin转入 rum asset，然后往指定 eth account 发相应的 ether，通过 mvm + registry 调用
  function mixinRumToEther(uint256 amount, address to) payable public {
    require(amount > 0, "invalid amount");
    IERC20(rumERC20Addr).transferFrom(msg.sender, address(this), amount);
    payable(to).transfer(amount * 1e10);  // ether 是18位精度，而 rum erc20 token 是 8 位精度
  }

  // 从mixin转入 rum asset，然后往指定的 eth account 发相应的 rum erc20，通过 mvm + registry 调用
  function mixinRumToRumERC20(uint256 amount, address to) payable public {
    IERC20(rumERC20Addr).transferFrom(msg.sender, to, amount);
  }

  // 将 ether 兑换成 rum erc20，通过 metamask/web3 api 调用
  function etherToRumERC20() payable public {
    uint256 amount = msg.value;
    require(amount >= 1e10, "invalid msg.value, msg.value < 1e10");
    require(getRumERC20Balance() * 1e10 >= amount, "insufficient funds");
    IERC20(rumERC20Addr).transfer(msg.sender, amount/1e10);
  }

  // 将 ether 兑换成 mixin rum asset：直接将 rum erc20 token 转入 mixin user_id 对应的 eth MixinUser address 就好了
  // 从 registry 的 contracts 变量中能通过 mixin user id 的变形获取到

  // Function to receive Ether. msg.data must be empty
  receive() external payable {}

  // Fallback function is called when msg.data is not empty
  fallback() external payable {}
}
