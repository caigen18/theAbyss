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
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


/// @title Position Token
/// @notice A token that represents a claim to a collateral pool and a short or long position.
/// The collateral pool acts as the owner of this contract and controls minting and redemption of these
/// tokens based on locked collateral in the pool.
/// NOTE: We eventually can move all of this logic into a library to avoid deploying all of the logic
/// every time a new market contract is deployed.
/// @author Phil Elsasser <phil@marketprotocol.io>
contract PositionToken is ERC20, Ownable {

    string public name;
    string public symbol;
    uint8 public decimals;

    MarketSide public MARKET_SIDE; // 0 = Long, 1 = Short
    enum MarketSide { Long, Short}

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 marketSide
    ) public
    {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = 5;
        MARKET_SIDE = MarketSide(marketSide);
    }

    /// @dev Called by our MarketContract (owner) to create a long or short position token. These tokens are minted,
    /// and then transferred to our recipient who is the party who is minting these tokens.  The collateral pool
    /// is the only caller (acts as the owner) because collateral must be deposited / locked prior to minting of new
    /// position tokens
    /// @param qtyToMint quantity of position tokens to mint (in base units)
    /// @param recipient the person minting and receiving these position tokens.
    function mintAndSendToken(
        uint256 qtyToMint,
        address recipient
    ) external onlyOwner
    {
        _mint(recipient, qtyToMint);
    }

    /// @dev Called by our MarketContract (owner) when redemption occurs.  This means that either a single user is redeeming
    /// both short and long tokens in order to claim their collateral, or the contract has settled, and only a single
    /// side of the tokens are needed to redeem (handled by the collateral pool)
    /// @param qtyToRedeem quantity of tokens to burn (remove from supply / circulation)
    /// @param redeemer the person redeeming these tokens (who are we taking the balance from)
    function redeemToken(
        uint256 qtyToRedeem,
        address redeemer
    ) external onlyOwner
    {
        _burn(redeemer, qtyToRedeem);
    }
}