/*
/%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%%
/%:::::$²²²²²²²²²²²²²$::::::::::::::::::::$²²²²²²²²²²²²²²²²²²²²²²²²²²²²²S:::::%%
/%:::::$   [enter]   $::::::::::::::::::::$                             $:::::%%
/%:::::$sssssssssssss$::::::::::::::::::::$     -x-  ABY/v0 -x-         $:::::%%
/%:::::::::   ::::::::::::::::::::::::::::$                             $:::::%%
/%:::::::: .' ::::   _  ::::::::::::::::::$  :/ solidity : m4ss, VAC    $:::::%%
/%:::::: .$ :: _.x%$$$%x. ::::::::::::::::$  :/ design   : VAC, m4ss    $:::::%%
/%:the: x$': .x$$$$²²'   `sSSs :::::::::::$  :/ IO :     : 1unacy       $:::::%%
/%:::: ,$²  x$$$$²'     : `²²'       :::::$  :/ stack    : m4ss         $:::::%%
/%:::: $$  x$$$$'  s$$$s  s$$s s$$$$s. :::$  :/ counsel  : 7dlm         $:::::%%
/%::: :$$.x$$$$'  $$² ²$$ $$$$ ss   $$. ::$  :/ math     : 1unacy, 7dlm $:::::%%
/%::: :$$$$$$$$ : $$   $$ $$$$ $$ : $$: ::$  :/ stratagem: 1unacy, VAC  $:::::%%
/%:::: $$$$$$$' : $$s s$$ $$$$ $$   $$' ::$                             $:::::%%
/%:::: `$$$$$' ::: ²$$$²  ²$$² ²$$$$$² :::$                             $:::::%%
/%::::: `²²² ::::::     ::    :       ::::$sssssssssssssssssssssssssssss$:::::%%
/%fz::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%%
*/

pragma solidity 0.5.2;

import "./UpgradeableTarget.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";


/// @title Upgradeable Token
/// @notice allows for us to update some of the needed functionality in our tokens post deployment. Inspiration taken
/// from Golems migrate functionality.
/// @author Phil Elsasser <phil@marketprotocol.io>
contract UpgradeableToken is Ownable, ERC20Burnable {

    address public upgradeableTarget;       // contract address handling upgrade
    uint256 public totalUpgraded;           // total token amount already upgraded

    event Upgraded(address indexed from, address indexed to, uint256 value);

    /*
    // EXTERNAL METHODS - TOKEN UPGRADE SUPPORT
    */

    /// @notice Update token to the new upgraded token
    /// @param value The amount of token to be migrated to upgraded token
    function upgrade(uint256 value) external {
        require(upgradeableTarget != address(0), "cannot upgrade with no target");

        burn(value);                    // burn tokens as we migrate them.
        totalUpgraded = totalUpgraded.add(value);

        UpgradeableTarget(upgradeableTarget).upgradeFrom(msg.sender, value);
        emit Upgraded(msg.sender, upgradeableTarget, value);
    }

    /// @notice Set address of upgrade target process.
    /// @param upgradeAddress The address of the UpgradeableTarget contract.
    function setUpgradeableTarget(address upgradeAddress) external onlyOwner {
        upgradeableTarget = upgradeAddress;
    }

}