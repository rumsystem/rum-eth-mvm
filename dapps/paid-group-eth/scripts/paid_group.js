// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

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

  // We get the contract to deploy
  const PaidGroup = await hre.ethers.getContractFactory("PaidGroup");
  console.log("Deploying PaidGroup ...")
  const version = "0.0.1";
  const invokeFee = ethers.utils.parseEther("0.1");
  const shareRatio = 80;
  const paidGroup = await upgrades.deployProxy(PaidGroup, [version, invokeFee, shareRatio], {initializer: 'initialize'});

  await paidGroup.deployed();

  console.log("PaidGroup deployed to:", paidGroup.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
