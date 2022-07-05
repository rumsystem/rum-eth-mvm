const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");
const utils = require("./utils.js");

describe("PaidGroup", function () {
  const platformReceiver = "0xF0E75E53f0AEC66E9536c7D9c7afCDB140aCDE19";
  let deployer = null;
  let addr1 = null;
  let paidGroup = null;

  before(async function() {
    const PaidGroup = await ethers.getContractFactory("PaidGroup");
    paidGroup = await PaidGroup.deploy();
    await paidGroup.deployed();

    // get current account address
    const [owner, _addr1] = await ethers.getSigners();
    deployer = owner.address;
    addr1 = _addr1;

    // invoke initialize
    let version = "0.0.1";
    let invokeFee = ethers.utils.parseEther("0.1");
    let shareRatio = BigNumber.from(70);
    const initializeTx = await paidGroup.initialize(version, invokeFee, shareRatio);
    await initializeTx.wait();

    expect(await paidGroup.getDappInfo()).to.deep.equal([
      "Paid Group",
      version,
      "Quorum Team",
      platformReceiver,
      deployer,
      invokeFee,
      shareRatio,
    ]);
  });

  it("Should not initialize dapp info again", async function(){
    // invoke initialize should failed
    let version = "0.0.2"
    let invokeFee = ethers.utils.parseEther("0.2");
    let shareRatio = BigNumber.from(80);
    await expect(paidGroup.initialize(version, invokeFee, shareRatio + 10)).to.be.revertedWith("Contract instance has already been initialized");
  });

  it("Should update dapp info by owner", async function(){
    // invoke updateDappInfo
    let version = "0.0.2"
    let invokeFee = ethers.utils.parseEther("0.2");
    let shareRatio = BigNumber.from(80);
    const updateDappInfoTx = await paidGroup.updateDappInfo(version, invokeFee, shareRatio);
    await updateDappInfoTx.wait();

    expect(await paidGroup.getDappInfo()).to.deep.equal([
      "Paid Group",
      version,
      "Quorum Team",
      platformReceiver,
      deployer,
      invokeFee,
      shareRatio,
    ]);
  });

  it("Should not update dapp info by invalid params", async function(){
    // invoke updateDappInfo
    let version = "0.0.2"
    let invokeFee = ethers.utils.parseEther("0.01");
    let shareRatio = 80

    // invaliad invokeFees
    const invalidInvokeFees = [0];
    for (const _invokeFee of invalidInvokeFees) {
      await expect(paidGroup.updateDappInfo(version, _invokeFee, shareRatio)).to.be.revertedWith("invalid invoke fee");
    }

    // invalid shareRatio
    const invalidShareRatios = [0, 101, 120];
    for (const _shareRatio of invalidShareRatios) {
      await expect(paidGroup.updateDappInfo(version, invokeFee, _shareRatio)).to.be.revertedWith("invalid share ratio");
    }
  });

  it("Should announce group price", async function(){
    let groupId = utils.newGroupID();
    let price = utils.newPrice();
    let duration = utils.newDuration();

    const dappInfo = await paidGroup.getDappInfo();
    const announcePriceTx = await paidGroup.addPrice(groupId, duration, price, { value: dappInfo.invokeFee});
    await announcePriceTx.wait();

    // get group price
    expect(await paidGroup.getPrice(groupId)).to.deep.equal(price);
    const [_groupOwner, _price, _duration] = await paidGroup.getPriceDetail(groupId);
    expect(_groupOwner).to.equal(deployer);
    expect(_price).to.equal(price);
    expect(_duration).to.equal(duration);

    // already announced
    await expect(paidGroup.addPrice(groupId, duration, price, { value: dappInfo.invokeFee})).to.be.revertedWith("group price already announced");
  });

  it("Should not announce group price with invalid params", async function(){
    let groupId = utils.newGroupID();
    let price = utils.newPrice();
    let duration = utils.newDuration();

    const dappInfo = await paidGroup.getDappInfo();

    // missing msg.value/invokeFee
    await expect(paidGroup.addPrice(groupId, duration, price)).to.be.revertedWith("invalid invoke fee");

    // invalid msg.value/invokeFee
    await expect(paidGroup.addPrice(groupId, duration, price, { value: dappInfo.invokeFee.add(1)})).to.be.revertedWith("invalid invoke fee");
    await expect(paidGroup.addPrice(groupId, duration, price, { value: dappInfo.invokeFee.sub(1)})).to.be.revertedWith("invalid invoke fee");

    // invalid groupId
    await expect(paidGroup.addPrice(0, duration, price, { value: dappInfo.invokeFee})).to.be.revertedWith("invalid group id");

    // invalid price
    await expect(paidGroup.addPrice(groupId, duration, 0, { value: dappInfo.invokeFee})).to.be.revertedWith("invalid price");

    // invalid duration
    await expect(paidGroup.addPrice(groupId, 0, price, { value: dappInfo.invokeFee})).to.be.revertedWith("invalid duration");
  });

  it("Should update group price by group owner", async function(){
    // add group price
    let groupId = utils.newGroupID();
    let price = utils.newPrice();
    let duration = utils.newDuration();

    const dappInfo = await paidGroup.getDappInfo();
    const announcePriceTx = await paidGroup.addPrice(groupId, duration, price, { value: dappInfo.invokeFee});
    await announcePriceTx.wait();

    // get group price
    expect(await paidGroup.getPrice(groupId)).to.deep.equal(price);

    // update group price
    let price2 = utils.newPrice();
    let duration2 = utils.newDuration();
    const updatePriceTx = await paidGroup.updatePrice(groupId, duration2, price2, { value: dappInfo.invokeFee});
    await updatePriceTx.wait();

    // get group price detail
    const [_groupOwner, _price, _duration] = await paidGroup.getPriceDetail(groupId);
    expect(_groupOwner).to.equal(deployer);
    expect(_price).to.equal(price2);
    expect(_duration).to.equal(duration2);

    // missing msg.value/invokeFee
    await expect(paidGroup.updatePrice(groupId, duration, price)).to.be.revertedWith("invalid invoke fee");

    // invalid group id
    await expect(paidGroup.updatePrice(0, duration, price, { value: dappInfo.invokeFee})).to.be.revertedWith("invalid group id");

    // only group owner can update price or duration
    /*
    await expect(paidGroup.connect(addr1).updatePrice(groupId, duration, price, { value: dappInfo.invokeFee, gasLimit: 50000 })).to.be.revertedWith("only group owner can update price");
    */
  });

  it("Should pay for group", async function(){
    // add group price
    let groupId = utils.newGroupID();
    let price = utils.newPrice();
    let duration = utils.newDuration();

    const dappInfo = await paidGroup.getDappInfo();
    await (await paidGroup.addPrice(groupId, duration, price, { value: dappInfo.invokeFee})).wait();

    // can not find group price
    await expect(paidGroup.pay(utils.newGroupID(), { value: utils.newPrice() })).to.be.revertedWith("can not find group price");

    // pay with invalid price
    await expect(paidGroup.pay(groupId, { value: 0 })).to.be.revertedWith("invalid pay price");
    await expect(paidGroup.pay(groupId, { value: price.add(1) })).to.be.revertedWith("invalid pay price");
    await expect(paidGroup.pay(groupId, { value: price.sub(1) })).to.be.revertedWith("invalid pay price");

    // have not paid
    expect(await paidGroup.isPaid(deployer, groupId)).to.equal(false);

    // pay for group
    const begin = utils.unixTimestamp();
    await (await paidGroup.pay(groupId, { value: price })).wait();

    // get paid detail
    const detail = await paidGroup.getPaidDetail(deployer, groupId);
    expect(await detail.groupId).to.equal(groupId);
    expect(await detail.price).to.equal(price);
    expect(await detail.expiredAt).to.above(begin + duration);

    // check if paid
    expect(await paidGroup.isPaid(deployer, groupId)).to.equal(true);

    // already paid
    await expect(paidGroup.pay(groupId, { value: price })).to.be.revertedWith("already paid");
  });
});
