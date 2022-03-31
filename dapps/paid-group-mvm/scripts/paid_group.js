// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const { BigNumber } = require("ethers");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // deploy library
  const BLS = await hre.ethers.getContractFactory("BLS");
  const bls = await BLS.deploy();
  await bls.deployed();
  console.log("deployed BLS contract at:", bls.address);

  // We get the contract to deploy
  const PaidGroup = await hre.ethers.getContractFactory("PaidGroupMVM", {
    libraries: {
      "BLS": bls.address,
    },
  });

  console.log("Deploying PaidGroupMVM ...")
  const version = "0.0.1";
  const invokeFee = 5 * 10 ** 8; // 5 CNB
  const shareRatio = 80;
  const process = BigNumber.from("0x63b02e33a9d63b87824e83d4c02dcf25");
  const paidGroup = await PaidGroup.deploy();
  await paidGroup.deployed();
  console.log("PaidGroupMVM deployed to:", paidGroup.address);

  const initializeTx = await paidGroup.initialize(version, invokeFee, shareRatio, process);
  await initializeTx.wait();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
