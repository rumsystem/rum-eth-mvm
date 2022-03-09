import sys
from config import conf
from config import w3, contract, send_tx, tx_params


def get_group_price(group_id):
    res = contract.functions.getPrice(group_id).call()
    print(f'group price: {res}')
    return res


def get_group_price_detail(group_id):
    res = contract.functions.getPriceDetail(group_id).call()
    print(f'group price plan: {res}')
    return res


def get_extra_logs(idx):
    # res = contract.functions.getExtraStrLogs(idx).call()
    # print(f'extra str logs {idx}: {res}')

    res = contract.functions.getExtraBytesLogs(idx).call()
    print(f'extra bytes logs {idx}: {res}')

    res = contract.functions.getExtraLogs(idx).call()
    print(f'extra logs {idx}: {res}')


def get_event_logs(idx):
    res = contract.functions.getEventLogs(idx).call()
    print(f'event logs {idx}: {res}')
    return res


def is_paid(user, group_id):
    res = contract.functions.isPaid(user, group_id).call()
    print(f'is_paid: {res}')
    return res


def get_paid_detail(user, group_id):
    res = contract.functions.getPaidDetail(user, group_id).call()
    print(f'paid detail: {res}')
    return res


group_id = 0xeea91a66b42d47eab752af98b9e6391b
duration = 60 * 60 * 24 * 365
price = 420000 * 2
user = w3.toChecksumAddress('0x729d862c8a47e0600e35fd4acef14e2b00b9d0cd')

for idx in range(2):
    get_extra_logs(idx)
    # get_event_logs(idx)
get_group_price(group_id)

get_group_price_detail(group_id)

# add group price
# tx = contract.functions.addPrice(group_id, group_owner, False, duration, price).buildTransaction(tx_params())
# print(send_tx(tx))
# get_group_price(group_id)
# get_group_price_detail(group_id)

# get member key
res = contract.functions.getMemberKey(user, group_id).call()
print('member key:', res)

# pay group price
# tx = contract.functions.pay(user, group_id).buildTransaction(tx_params())
# print(send_tx(tx))

# get paid detail
get_paid_detail(user, group_id)

# check if user has paid
is_paid(user, group_id)
