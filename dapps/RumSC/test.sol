// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/RumSC.sol";

contract TestRumSC {
    //struct Receipt {
    //bytes32 blockHash;
    //uint blockNumber;
    //bytes32 contractAddress;
    //uint cumulativeGasUsed;
    //bytes32 effectiveGasPrice;
    //bytes32 from;
    //uint gasUsed;
    //string[] logs;
    //string logsBloom;
    //bool status;
    //bytes32 to;
    //bytes32 transactionHash;
    //uint transactionIndex;
    //bytes32 contentType;
    //string[] rawLogs;
    //}

    //struct SaveResult {
    //bytes32 tx;
    //Receipt receipt;
    //string[] logs;
    //}

    function testRumSCUsingDeployedContract() public {
        RumSC rumsc = RumSC(DeployedAddresses.RumSC());

        uint256 postCount = rumsc.getLength();

        Assert.isAtLeast(
            postCount,
            0,
            "Posts length should be a normal number"
        );

        rumsc.save(
            "test",
            "0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51",
            "PIP:2001",
            "test",
            "test",
            "0xfbd71db11e7d0038646252e19da21f68befd9db2d79dde02dded74088c2338aa",
            "9ca7c049d6c7b5509951eec902f9145265e666008b15af59f3405295c2a07568569fb6f2235176e9ca8d4ba70eb94c04e656db379774b80a694681e2b0c0bd3300"
        );

        Assert.isAbove(
            rumsc.getLength(),
            postCount,
            "Posts length should greater than pre post count"
        );

        string memory id; // identity
        string memory user_address; // identity
        string memory protocol; // content_type
        string memory meta; // content_meta
        string memory data; // content_data
        string memory hash; // content_hash
        string memory signature; // content_signature

        (id, user_address, protocol, meta, data, hash, signature) = rumsc.posts(
            postCount
        );

        Assert.equal(id, "test", "id should be test");
        Assert.equal(
            user_address,
            "0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51",
            "user_address should be 0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51"
        );
        Assert.equal(protocol, "PIP:2001", "protocol should be PIP2001");
        Assert.equal(meta, "test", "meta should be test");
        Assert.equal(data, "test", "data should be test");
        Assert.equal(
            hash,
            "0xfbd71db11e7d0038646252e19da21f68befd9db2d79dde02dded74088c2338aa",
            "hash should be 0xfbd71db11e7d0038646252e19da21f68befd9db2d79dde02dded74088c2338aa"
        );
        Assert.equal(
            signature,
            "9ca7c049d6c7b5509951eec902f9145265e666008b15af59f3405295c2a07568569fb6f2235176e9ca8d4ba70eb94c04e656db379774b80a694681e2b0c0bd3300",
            "signature should be 9ca7c049d6c7b5509951eec902f9145265e666008b15af59f3405295c2a07568569fb6f2235176e9ca8d4ba70eb94c04e656db379774b80a694681e2b0c0bd3300"
        );
    }

    function testRumSCWithNewRumSC() public {
        RumSC rumsc = new RumSC();

        Assert.equal(rumsc.getLength(), 0, "Posts length should be 0");

        rumsc.save(
            "test",
            "0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51",
            "PIP:2001",
            "test",
            "test",
            "0xfbd71db11e7d0038646252e19da21f68befd9db2d79dde02dded74088c2338aa",
            "9ca7c049d6c7b5509951eec902f9145265e666008b15af59f3405295c2a07568569fb6f2235176e9ca8d4ba70eb94c04e656db379774b80a694681e2b0c0bd3300"
        );

        Assert.isAbove(
            rumsc.getLength(),
            0,
            "Posts length should greater than 0"
        );

        string memory id; // identity
        string memory user_address; // identity
        string memory protocol; // content_type
        string memory meta; // content_meta
        string memory data; // content_data
        string memory hash; // content_hash
        string memory signature; // content_signature

        (id, user_address, protocol, meta, data, hash, signature) = rumsc.posts(
            0
        );

        Assert.equal(id, "test", "id should be test");
        Assert.equal(
            user_address,
            "0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51",
            "user_address should be 0x2AeF3da35e9A2EC29aE25A04d9C9e92110910A51"
        );
        Assert.equal(protocol, "PIP:2001", "protocol should be PIP2001");
        Assert.equal(meta, "test", "meta should be test");
        Assert.equal(data, "test", "data should be test");
        Assert.equal(
            hash,
            "0xfbd71db11e7d0038646252e19da21f68befd9db2d79dde02dded74088c2338aa",
            "hash should be 0xfbd71db11e7d0038646252e19da21f68befd9db2d79dde02dded74088c2338aa"
        );
        Assert.equal(
            signature,
            "9ca7c049d6c7b5509951eec902f9145265e666008b15af59f3405295c2a07568569fb6f2235176e9ca8d4ba70eb94c04e656db379774b80a694681e2b0c0bd3300",
            "signature should be 9ca7c049d6c7b5509951eec902f9145265e666008b15af59f3405295c2a07568569fb6f2235176e9ca8d4ba70eb94c04e656db379774b80a694681e2b0c0bd3300"
        );
    }
}
