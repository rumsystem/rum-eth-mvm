const RumSC = artifacts.require("RumSC");

module.exports = function(deployer) {
  // deployer.deploy(RumSC);
  // Don't deploy this contract if it has already been deployed
  deployer.deploy(RumSC, {overwrite: false});
};
