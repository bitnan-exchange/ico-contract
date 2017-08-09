var BitnanRewardToken = artifacts.require("./BitnanRewardToken.sol");

module.exports = function(deployer) {
  deployer.deploy(BitnanRewardToken, 0x33dc87951559aed590dfb399ad8578bfc587c741);
};
