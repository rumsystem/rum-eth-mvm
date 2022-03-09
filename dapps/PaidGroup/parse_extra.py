import sys
import enum
from dataclasses import dataclass


class Action(enum.Enum):
    AnnouceGroupPrice = 0
    PayForGroup = 1


@dataclass
class Extra:
    action: Action
    group_id: int
    rum_address: int
    amount: int = 0
    duration: int = 0

    def hex(self):
        return (
            f"{self.action.value:02x}"
            f"{self.group_id:032x}"
            f"{self.rum_address:040x}"
            f"{int(self.amount):016x}"
            f"{int(self.duration):08x}"
        )


def parse_extra(extra_str):
    payload = bytes.fromhex(extra_str)
    extra = Extra(
        action=Action(int(payload[0:1].hex(), 16)),
        group_id=int(payload[1:17].hex(), 16),
        rum_address=int(payload[17:37].hex(), 16),
        amount=int(payload[37:45].hex(), 16),
        duration=int(payload[45:49].hex(), 16),
    )
    return extra


def get_extra_str():
    announce_group_price_extra = Extra(
        action=Action.AnnouceGroupPrice,
        group_id=0xeea91a66b42d47eab752af98b9e6391b,  # quorum group id
        # group owner 的 quorum帐号的地址 (eth地址)；只是记录下来，暂时没有实际用途
        rum_address=0xcc224ef7341992368fe95c82d3588ae40fbbb614,
        amount=int(10 * 1e8),  # 费用，对 CNB 来说，10 * 1e8 ，实际支付 10 个 CNB
        duration=1 * 365 * 24 * 60 * 60  # 会员有效期，单位是秒
    )
    pay_group_extra = Extra(
        action=Action.PayForGroup,
        group_id=0xeea91a66b42d47eab752af98b9e6391b,  # quorum group id
        # 付费用户的 quorum帐号的地址 (eth地址)；用来查询该用户是否是某个 group 的付费会员
        rum_address=0x729d862c8a47e0600e35fd4acef14e2b00b9d0cd,
    )
    print('announce group price extra:', announce_group_price_extra.hex())
    print('pay group extra:', pay_group_extra.hex())
    print(parse_extra(announce_group_price_extra.hex()))
    print(parse_extra(pay_group_extra.hex()))


if __name__ == '__main__':
    get_extra_str()
