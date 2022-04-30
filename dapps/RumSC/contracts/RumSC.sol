// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract RumSC {
    struct Post {
        string id; // identity
        string user_address; // poster_address
        string protocol; // content_type
        string meta; // content_meta
        string data; // content_data
        string hash; // content_hash
        string signature; // content_signature
    }

    event NewPost(
        string id,
        string user_address,
        string indexed protocol,
        string meta,
        string data,
        string hash,
        string signature
    );

    Post[] public posts;

    function save(
        string memory id,
        string memory user_address,
        string memory protocol,
        string memory meta,
        string memory data,
        string memory hash,
        string memory signature
    ) public {
        posts.push(
            Post({
                id: id,
                user_address: user_address,
                protocol: protocol,
                meta: meta,
                data: data,
                hash: hash,
                signature: signature
            })
        );
        emit NewPost(id, user_address, protocol, meta, data, hash, signature);
    }

    function getLength() public view returns (uint256) {
        return posts.length;
    }
}
