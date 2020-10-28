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
import "./UpgradableToken.sol";


/// @title Upgradeable Token Mock for testing only.
/// @notice A token to be able to test upgrade from another token
/// @author Phil Elsasser <phil@marketprotocol.io>
contract UpgradeableTokenMock is UpgradeableToken, UpgradeableTarget {

    address public PREVIOUS_TOKEN_ADDRESS;

    constructor(address previousTokenAddress) public {
        PREVIOUS_TOKEN_ADDRESS = previousTokenAddress;
    }

    /*
    // EXTERNAL METHODS - TOKEN UPGRADE SUPPORT
    */
    function upgradeFrom(address from, uint256 value) external {
        require(msg.sender == PREVIOUS_TOKEN_ADDRESS, "Can only be called by PREVIOUS_TOKEN_ADDRESS");    // this can only be called from the  previous token!
        _mint(from, value);
    }
}
