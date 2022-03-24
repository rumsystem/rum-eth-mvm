from config import conf, GROUP_ID
from config import contract, send_tx, tx_params

duration = 60 * 60 * 24 * 365
announce_fee = 1 * 10 ** 8
group_price = 42 * 10 ** 16


def get_dapp_info():
    res = contract.functions.getDappInfo().call()
    print(f'dapp info: {res}')
    return res


def get_group_price(group_id):
    res = contract.functions.getPrice(group_id).call()
    print(f'group price: {res}')
    return res


def get_group_price_detail(group_id):
    res = contract.functions.getPriceDetail(group_id).call()
    print(f'group price plan: {res}')
    return res


def is_paid(user, group_id):
    res = contract.functions.isPaid(user, group_id).call()
    print(f'is_paid: {res}')
    return res


def get_paid_detail(user, group_id):
    res = contract.functions.getPaidDetail(user, group_id).call()
    print(f'paid detail: {res}')
    return res


get_dapp_info()
get_group_price(GROUP_ID)
get_group_price_detail(GROUP_ID)

# add group price
print('announce group price ...')
tx = contract.functions.addPrice(
    GROUP_ID, duration, group_price).buildTransaction(tx_params(value=announce_fee))
print(send_tx(tx))

get_group_price(GROUP_ID)
get_group_price_detail(GROUP_ID)

# get member key
res = contract.functions.getMemberKey(conf.pub_key, GROUP_ID).call()
print(f'member key: {res}')

# pay group price
print('invoke pay ...')
tx = contract.functions.pay(GROUP_ID).buildTransaction(
    tx_params(value=group_price))
print(f'tx: {tx}')
print(send_tx(tx))

get_paid_detail(conf.pub_key, GROUP_ID)
is_paid(conf.pub_key, GROUP_ID)
