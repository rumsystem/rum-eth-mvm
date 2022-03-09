import json
from dataclasses import dataclass

from web3 import Web3, HTTPProvider


@dataclass
class Config:
    rpc_url: str
    chain_id: int
    pub_key: str
    priv_key: str
    abi: dict
    contract_address: str


def load_abi(path):
    with open(path, 'r') as f:
        return json.load(f)


abi_json_path = './abi.json'
conf = Config(
    rpc_url='http://149.56.22.113:8545',
    chain_id=19890609,
    pub_key='0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    priv_key='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    abi=load_abi(abi_json_path),
    contract_address=Web3.toChecksumAddress('0x79c06446d0871e505123e9c80346fccb59174208'),
)


w3 = Web3(HTTPProvider(conf.rpc_url))
contract = w3.eth.contract(
    address=conf.contract_address, abi=conf.abi)  # type: ignore


def tx_params():
    tx_params = {
        'from': conf.pub_key,
        'gas': 300000,
        'gasPrice': w3.eth.gasPrice,
        'chainId': conf.chain_id,
        'nonce': w3.eth.getTransactionCount(conf.pub_key),
    }
    return tx_params


def send_tx(tx):
    signed = w3.eth.account.signTransaction(tx, conf.priv_key)
    tx_hash = w3.eth.sendRawTransaction(signed.rawTransaction)
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

    print('tx_hash:', tx_hash.hex())

    return tx_receipt
