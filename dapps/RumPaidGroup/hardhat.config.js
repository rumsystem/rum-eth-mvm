require('dotenv').config({ path: __dirname + '/.env' });

const { removeConsoleLog } = require('hardhat-preprocessor');
require("@nomiclabs/hardhat-waffle");
require("@openzeppelin/hardhat-upgrades")
require('hardhat-deploy');
require('solidity-coverage');

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
function prepareHardhatConfigs() {
  // The hardhat config object will be returned.
  const config = {
    networks: {
      quorum: {
        url: process.env.QUORUM_RPC_URL,
        chainId: parseInt(process.env.QUORUM_CHAIN_ID),
        hardfork: 'arrowGlacier',
        accounts: [
          process.env.DEPLOYER_PRIV_KEY,
          process.env.USER1,
        ],
        from: process.env.DEPLOYER_PUB_KEY,
        gas: 'auto',
        gasPrice: 'auto',
      },
    },
    solidity: {
      version: '0.8.13',
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
    mocha: {
      timeout: 40000
    },

    // Remove console.log when deploying to public networks
    preprocess: {
      eachLine: removeConsoleLog(
        (hre) => hre.network.name !== 'hardhat' && hre.network.name !== 'localhost'
      ),
    },
  };

  return config;
}

module.exports = prepareHardhatConfigs();
