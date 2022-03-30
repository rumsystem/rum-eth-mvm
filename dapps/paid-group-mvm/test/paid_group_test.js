const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");
const utils = require("./utils.js");

describe("PaidGroup", function () {
  const platformReceiver = "0x0001beb05804f083498eac0faf6d7fbcd6940001";
  let deployer = null;
  let process = BigNumber.from("0x25871250aba63f0b835837967fb48e9e");
  let addr1 = null;
  let paidGroup = null;

  before(async function() {
    const BLS = await hre.ethers.getContractFactory("BLS");
    const bls = await BLS.deploy();
    await bls.deployed();
    console.log("deployed BLS contract at:", bls.address);

    const PaidGroup = await ethers.getContractFactory("PaidGroupMVM", {
      libraries: {
        "BLS": bls.address,
      }
    });
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
    const initializeTx = await paidGroup.initialize(version, invokeFee, shareRatio, process);
    await initializeTx.wait();

    expect(await paidGroup.getDappInfo()).to.deep.equal([
      "Paid Group",
      version,
      "Quorum Team",
      platformReceiver,
      deployer,
      invokeFee,
      shareRatio,
      process,
    ]);
  });

  it("Should not initialize dapp info again", async function(){
    // invoke initialize should failed
    let version = "0.0.2"
    let invokeFee = ethers.utils.parseEther("0.2");
    let shareRatio = BigNumber.from(80);
    await expect(paidGroup.initialize(version, invokeFee, shareRatio + 10, process)).to.be.revertedWith("Contract instance has already been initialized");
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
      process,
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
});
