/**
 * Created by yinyu on 2017/8/4.
 */
var BitnanRewardToken = artifacts.require("BitnanRewardToken");
var testAccount = '0xf4d464f7cf62ab50f904180d7243c9523d834204';
contract('BitnanRewardToken', function(accounts) {
    it("start the ico", function() {
        var brt;
        var owner;
        return BitnanRewardToken.deployed().then(function(instance) {
            brt = instance;
            console.log("BRT contract address: " + brt.address);
            return brt.owner.call({from: testAccount});
        }).then(function(_owner) {
            owner = _owner;
            console.log(owner);
            return brt.start.call({from: owner});
        }).then(function(res) {
            return !res || res.length == 0;
        }).then(function(result) {
            assert.equal(result, true);
        })
    });
    //it("transfer eth to brt", function() {
    //    var brt;
    //    var owner;
    //    return BitnanRewardToken.deployed().then(function(instance) {
    //        brt = instance;
    //        return brt.owner.call();
    //    }).then(function(_owner) {
    //        owner = _owner;
    //        web3.eth.sendTransaction({from: testAccount, to: owner, value: web3.toWei(1), gas: 500000 });
    //        return brt.start(10, {from: owner});
    //    }).then(function() {
    //        return web3.eth.sendTransaction({from: testAccount, to: brt.address, value: web3.toWei(331.07), gas: 500000 });
    //    }).then(function(tx) {
    //        return brt.balanceOf(testAccount);
    //    }).then(function(balance) {
    //        assert.equal(balance.toNumber(), (331.07e+18) * 3000, "phase token amount error" );
    //    })
    //});
    it("close ico", function() {
        var brt;
        var owner;
        return BitnanRewardToken.deployed().then(function(instance) {
            brt = instance;
            return brt.owner.call();
        }).then(function(_owner) {
            owner = _owner;
            web3.eth.sendTransaction({from: testAccount, to: owner, value: web3.toWei(1), gas: 500000 });
            return brt.start(10, {from: owner});
        }).then(function() {
            return web3.eth.sendTransaction({from: testAccount, to: brt.address, value: web3.toWei(6000), gas: 500000 });
        }).then(function() {
            return brt.close({from: owner});
        }).then(function() {
            return brt.balanceOf(owner);
        }).then(function(balance) {
            assert.equal(balance.toNumber(), 1.08e+25, 'close ico error');
        })
    })
});