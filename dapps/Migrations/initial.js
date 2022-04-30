const Migrations = artifacts.require("Migrations");

module.exports = function(deployer) {
    // deployer.deploy(Migrations);
    // Don't deploy this contract if it has already been deployed
    deployer.deploy(Migrations, { overwrite: false });
};
