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

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";


// dummy ERC20 token for testing purposes
contract CollateralToken is ERC20 {

    string public name;
    string public symbol;
    uint8 public decimals;


    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint256 initialSupply,
        uint8 tokenDecimals
    ) public
    {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = tokenDecimals;
        _mint(msg.sender, initialSupply * 10**uint(decimals));
    }
}
