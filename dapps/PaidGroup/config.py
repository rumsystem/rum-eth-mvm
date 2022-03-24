import json
import os
from dataclasses import dataclass

from web3 import Web3, HTTPProvider

PUB_KEY = os.environ['PUB_KEY']
PRIV_KEY = os.environ['PRIV_KEY']
CHANNEL = os.environ['CHANNEL'].lower()
if CHANNEL == 'eth':
    CONTRACT_ADDRESS = os.environ['ETH_CONTRACT_ADDRESS']
    ABI_PATH = os.environ['ETH_ABI_PATH']
elif CHANNEL == 'mvm':
    CONTRACT_ADDRESS = os.environ['MVM_CONTRACT_ADDRESS']
    ABI_PATH = os.environ['MVM_ABI_PATH']
else:
    raise ValueError(f'un-support channel: {CHANNEL}')
GROUP_ID = int(os.environ['GROUP_ID'], base=16)
USER = Web3.toChecksumAddress(os.environ['USER'])


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


conf = Config(
    rpc_url='http://149.56.22.113:8545',
    chain_id=19890609,
    pub_key=Web3.toChecksumAddress(PUB_KEY),
    priv_key=PRIV_KEY,
    abi=load_abi(ABI_PATH),
    contract_address=Web3.toChecksumAddress(CONTRACT_ADDRESS),
)

w3 = Web3(HTTPProvider(conf.rpc_url))
contract = w3.eth.contract(
    address=conf.contract_address, abi=conf.abi)  # type: ignore


def tx_params(value=None):
    global conf, w3
    tx_params = {
        'from': conf.pub_key,
        'gas': 300000,
        'gasPrice': w3.eth.gasPrice,
        'chainId': conf.chain_id,
        'nonce': w3.eth.getTransactionCount(conf.pub_key),
    }
    if value:
        tx_params['value'] = value

    return tx_params


def send_tx(tx):
    global w3
    signed = w3.eth.account.signTransaction(tx, conf.priv_key)
    tx_hash = w3.eth.sendRawTransaction(signed.rawTransaction)
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

    print('tx_hash:', tx_hash.hex())

    return tx_receipt
