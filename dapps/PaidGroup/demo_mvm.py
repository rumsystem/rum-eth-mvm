from config import contract, GROUP_ID, USER


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

# get member key
res = contract.functions.getMemberKey(USER, GROUP_ID).call()
print('member key:', res)

# get paid detail
get_paid_detail(USER, GROUP_ID)

# check if user has paid
is_paid(USER, GROUP_ID)
