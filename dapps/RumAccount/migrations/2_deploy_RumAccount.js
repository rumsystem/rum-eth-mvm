const RumAccount = artifacts.require("RumAccount");

module.exports = function(deployer) {
  // deployer.deploy(RumAccount);
  // Don't deploy this contract if it has already been deployed
  deployer.deploy(RumAccount, {overwrite: false});
};
