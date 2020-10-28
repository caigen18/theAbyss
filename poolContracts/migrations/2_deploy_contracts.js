var GenericStorage = artifacts.require('./GenericStorage');
var GenericUpgrade = artifacts.require('./GenericUpgrade');
var GenericRole = artifacts.require('./GenericRole');
var GenericSettings = artifacts.require('./GenericSettings');
var GenericCollectible = artifacts.require('./GenericCollectible');
var GenericMarket = artifacts.require('./GenericMarket');

module.exports = function(deployer) {
    //var storage;


// Deploy the Storage contract
    deployer.deploy(GenericStorage)
        // Wait until the storage contract is deployed
        .then(() => GenericStorage.deployed({gas: 4200000,
      gasPrice: web3.toWei("11", "gwei")}))
        
        .then(() => deployer.deploy(GenericRole, GenericStorage.address,{gas: 4200000,
      gasPrice: web3.toWei("11", "gwei")}))

        .then(() => deployer.deploy(GenericSettings, GenericStorage.address,{gas: 4200000,
      gasPrice: web3.toWei("11", "gwei")}))

        .then(() => deployer.deploy(GenericCollectible, GenericStorage.address,{gas: 4200000,
      gasPrice: web3.toWei("11", "gwei")}))

        .then(() => deployer.deploy(GenericMarket, GenericStorage.address,{gas: 4200000,
      gasPrice: web3.toWei("11", "gwei")}))

        .then(() => deployer.deploy(GenericUpgrade, GenericStorage.address,{gas: 4200000,
      gasPrice: web3.toWei("11", "gwei")}));

      

}

