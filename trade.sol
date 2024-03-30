// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Import interfaces of the contracts
import "./Pool.sol";
import "./Router.sol";

contract LeveragedBTCUSDC {
    // Define variables for Pool and Router contracts
    Pool private poolContract;
    Router private routerContract;

    // Constructor to set the addresses of Pool and Router contracts
    constructor(address _poolAddress, address _routerAddress) {
        poolContract = Pool(_poolAddress);
        routerContract = Router(_routerAddress);
    }

    // Function to open a 3x leverage long position on BTC-USDC with stop-loss
    function openLongPositionWithLeverageAndStopLoss() external {
        // Define trading parameters
        address account = msg.sender; // Account initiating the transaction
        address btcToken = address(0x...); // Address of BTC token
        address usdcToken = address(0x...); // Address of USDC token
        uint256 pairIndex = poolContract.getPairIndex(btcToken, usdcToken); // Get trading pair index
        TradeType tradeType = TradeType.LIMIT; // Using limit order
        int256 collateral = 50000 * 10**18; // 50,000 USDC as collateral
        uint256 openPrice = getCurrentPriceOfBTCUSDC(); // Get current BTC-USDC price
        bool isLong = true; // Opening a long position
        uint256 sizeAmount = calculatePositionSize(openPrice, collateral); // Calculate position size
        uint256 maxSlippage = 1000; // 10% maximum slippage allowed
        NetworkFeePaymentType paymentType = NetworkFeePaymentType.USDC; // Network fee payment in USDC
        uint256 networkFeeAmount = calculateNetworkFee(); // Calculate network fee

        // Define stop-loss parameters
        uint256 slPrice = openPrice * 95 / 100; // 5% below the opening price
        uint256 sl = calculateStopLossAmount(openPrice, slPrice); // Calculate stop-loss amount
        uint256 slNetworkFeeAmount = calculateNetworkFee(); // Calculate network fee for stop loss

        // Create increase order with stop-loss
        routerContract.createIncreaseOrderWithTpSl(TradingTypes.IncreasePositionWithTpSlRequest({
            account: account,
            pairIndex: pairIndex,
            tradeType: tradeType,
            collateral: collateral,
            openPrice: openPrice,
            isLong: isLong,
            sizeAmount: sizeAmount,
            tpPrice: 0, // No take-profit for this order
            tp: 0,
            slPrice: slPrice,
            sl: sl,
            maxSlippage: maxSlippage,
            paymentType: paymentType,
            networkFeeAmount: networkFeeAmount,
            tpNetworkFeeAmount: 0,
            slNetworkFeeAmount: slNetworkFeeAmount
        }));
    }

    // Function to get current price of BTC-USDC from an oracle or other source
    function getCurrentPriceOfBTCUSDC() internal view returns (uint256) {
        // Implement logic to fetch current price from an oracle or other source
        return 50000; // Placeholder value for demonstration
    }

    // Function to calculate position size based on leverage and collateral
    function calculatePositionSize(uint256 price, uint256 collateral) internal pure returns (uint256) {
        // Implement logic to calculate position size based on leverage and collateral
        return collateral / price * 3; // 3x leverage
    }

    // Function to calculate stop-loss amount based on open price and stop-loss price
    function calculateStopLossAmount(uint256 openPrice, uint256 slPrice) internal pure returns (uint256) {
        // Implement logic to calculate stop-loss amount
        return (openPrice - slPrice); // Absolute amount to be reduced in case of stop-loss trigger
    }

    // Function to calculate network fee
    function calculateNetworkFee() internal pure returns (uint256) {
        // Implement logic to calculate network fee
        return 100; // Placeholder value for demonstration
    }
}
