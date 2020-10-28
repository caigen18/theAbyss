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

import "./CollateralToken.sol";


/// token with initial grant to all addresses
contract InitialAllocationCollateralToken is CollateralToken {

    uint256 public INITIAL_TOKEN_ALLOCATION;
    uint256 public totalTokenAllocationsRequested;
    mapping(address => bool) isInitialAllocationClaimed;

    event AllocationClaimed(address indexed claimeeAddress);

    /// @dev creates a token that allows for all addresses to retrieve an initial token allocation.
    constructor (
        string memory tokenName,
        string memory tokenSymbol,
        uint256 initialTokenAllocation,
        uint8 tokenDecimals
    ) public CollateralToken(
        tokenName,
        tokenSymbol,
        initialTokenAllocation,
        tokenDecimals
    ){
        INITIAL_TOKEN_ALLOCATION = initialTokenAllocation * (10 ** uint256(decimals));
    }

    /// @notice allows caller to claim a one time allocation of tokens.
    function getInitialAllocation() external {
        require(!isInitialAllocationClaimed[msg.sender]);
        isInitialAllocationClaimed[msg.sender] = true;
        _mint(msg.sender, INITIAL_TOKEN_ALLOCATION);
        totalTokenAllocationsRequested++;
        emit AllocationClaimed(msg.sender);
    }

    /// @notice check to see if an address has already claimed their initial allocation
    /// @param claimee address of the user claiming their tokens
    function isAllocationClaimed(address claimee) external view returns (bool) {
        return isInitialAllocationClaimed[claimee];
    }
}
