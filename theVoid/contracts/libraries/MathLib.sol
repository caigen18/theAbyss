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


/// @title Math function library with overflow protection inspired by Open Zeppelin
library MathLib {

    int256 constant INT256_MIN = int256((uint256(1) << 255));
    int256 constant INT256_MAX = int256(~((uint256(1) << 255)));

    function multiply(uint256 a, uint256 b) pure internal returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b,  "MathLib: multiplication overflow");

        return c;
    }

    function divideFractional(
        uint256 a,
        uint256 numerator,
        uint256 denominator
    ) pure internal returns (uint256)
    {
        return multiply(a, numerator) / denominator;
    }

    function subtract(uint256 a, uint256 b) pure internal returns (uint256) {
        require(b <= a, "MathLib: subtraction overflow");
        return a - b;
    }

    function add(uint256 a, uint256 b) pure internal returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "MathLib: addition overflow");
        return c;
    }

    /// @notice determines the amount of needed collateral for a given position (qty and price)
    /// @param priceFloor lowest price the contract is allowed to trade before expiration
    /// @param priceCap highest price the contract is allowed to trade before expiration
    /// @param qtyMultiplier multiplier for qty from base units
    /// @param longQty qty to redeem
    /// @param shortQty qty to redeem
    /// @param price of the trade
    function calculateCollateralToReturn(
        uint priceFloor,
        uint priceCap,
        uint qtyMultiplier,
        uint longQty,
        uint shortQty,
        uint price
    ) pure internal returns (uint)
    {
        uint neededCollateral = 0;
        uint maxLoss;
        if (longQty > 0) {   // calculate max loss from entry price to floor
            if (price <= priceFloor) {
                maxLoss = 0;
            } else {
                maxLoss = subtract(price, priceFloor);
            }
            neededCollateral = multiply(multiply(maxLoss, longQty),  qtyMultiplier);
        }

        if (shortQty > 0) {  // calculate max loss from entry price to ceiling;
            if (price >= priceCap) {
                maxLoss = 0;
            } else {
                maxLoss = subtract(priceCap, price);
            }
            neededCollateral = add(neededCollateral, multiply(multiply(maxLoss, shortQty),  qtyMultiplier));
        }
        return neededCollateral;
    }

    /// @notice determines the amount of needed collateral for minting a long and short position token
    function calculateTotalCollateral(
        uint priceFloor,
        uint priceCap,
        uint qtyMultiplier
    ) pure internal returns (uint)
    {
        return multiply(subtract(priceCap, priceFloor), qtyMultiplier);
    }

    /// @notice calculates the fee in terms of base units of the collateral token per unit pair minted.
    function calculateFeePerUnit(
        uint priceFloor,
        uint priceCap,
        uint qtyMultiplier,
        uint feeInBasisPoints
    ) pure internal returns (uint)
    {
        uint midPrice = add(priceCap, priceFloor) / 2;
        return multiply(multiply(midPrice, qtyMultiplier), feeInBasisPoints) / 10000;
    }
}
