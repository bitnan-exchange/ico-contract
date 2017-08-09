var Migrations = artifacts.require("./Migrations.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations, 0x33dc87951559aed590dfb399ad8578bfc587c741);
};
