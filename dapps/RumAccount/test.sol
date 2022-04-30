// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/RumAccount.sol";

contract TestRumAccount {
    function testRumAccountUsingDeployedContract() public {
        RumAccount rumaccount = RumAccount(DeployedAddresses.RumAccount());

        rumaccount.bind(
            0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51,
            "test",
            "test",
            "test",
            "test"
        );

        address user;
        string memory payment_provider;
        string memory payment_account;
        string memory meta;
        string memory memo;

        (user, payment_provider, payment_account, meta, memo) = rumaccount
            .account(0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51, "test");

        Assert.equal(
            user,
            0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51,
            "user should be 0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51"
        );
        Assert.equal(payment_provider, "test", "meta should be test");
        Assert.equal(payment_account, "test", "payment_account should be test");
        Assert.equal(meta, "test", "meta should be test");
        Assert.equal(memo, "test", "memo should be test");

        Assert.equal(
            rumaccount.userAddress("test", "test"),
            0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51,
            "addresses length should be 0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51"
        );
        Assert.isAbove(
            rumaccount.providerUsersCount("test"),
            0,
            "provider users count should greater than 0"
        );
    }

    function testRumAccountWithNewRumSC() public {
        RumAccount rumaccount = new RumAccount();

        rumaccount.bind(
            0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51,
            "test",
            "test",
            "test",
            "test"
        );

        address user;
        string memory payment_provider;
        string memory payment_account;
        string memory meta;
        string memory memo;

        (user, payment_provider, payment_account, meta, memo) = rumaccount
            .account(0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51, "test");

        Assert.equal(
            user,
            0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51,
            "user should be 0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51"
        );
        Assert.equal(payment_provider, "test", "meta should be test");
        Assert.equal(payment_account, "test", "payment_account should be test");
        Assert.equal(meta, "test", "meta should be test");
        Assert.equal(memo, "test", "memo should be test");

        Assert.equal(
            rumaccount.userAddress("test", "test"),
            0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51,
            "addresses length should be 0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51"
        );
        Assert.isAbove(
            rumaccount.providerUsersCount("test"),
            0,
            "provider users count should greater than 0"
        );
    }
}
