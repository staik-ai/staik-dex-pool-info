// SPDX-License-Identifier: UNLICENSED

//     ███████╗████████╗ █████╗ ██╗██╗  ██╗    █████╗ ██╗
//     ██╔════╝╚══██╔══╝██╔══██╗██║██║ ██╔╝   ██╔══██╗██║
//     ███████╗   ██║   ███████║██║█████╔╝    ███████║██║
//     ╚════██║   ██║   ██╔══██║██║██╔═██╗    ██╔══██║██║
//     ███████║   ██║   ██║  ██║██║██║  ██╗██╗██║  ██║██║
//     ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// /// @notice: Import instance of Open Zeppelin Initializable contract.
// /// @dev: Initializer control mechanism - called manually post-deployment
// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

// /// @notice: Import instance of officially forked Open Zeppelin Ownable contract.
// /// @dev: Access control contract making the "onlyOwner" modifier available
// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/////////////////////////////////////////////////////////////////////////////////////


pragma solidity 0.8.18;
pragma abicoder v2;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function balanceOf(address) external view returns (uint256);
}

interface IUniswapV3Pool {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function fee() external view returns (uint24);
    function slot0() external view returns (uint160 sqrtPriceX96, int24, uint16, uint16, uint16, uint8, bool);
    function ticks(int24 tickLower, int24 tickUpper) external view returns (uint128 liquidity, int24 cardinality, uint16 feeGrowthInside0LastX128, uint16 feeGrowthInside1LastX128, uint128 tokensOwed0, uint128 tokensOwed1);
    function balanceOf(address owner, int24 tickLower, int24 tickUpper) external view returns (uint128);
    function positions(int24 tickLower, int24 tickUpper) external view returns (uint128, uint256, uint256);    
}

interface IUniswapV3PoolDerivedState is IUniswapV3Pool {
    function observe(uint32 time) external view returns (uint256 price0Cumulative, uint256 price1Cumulative, uint32 blockTimestamp);
    function getFeeGrowthInside(int24 tickLower, int24 tickUpper) external view returns (uint256 feeGrowthInside0X128, uint256 feeGrowthInside1X128);
}

interface IUniswapV2Pair {
    function totalSupply() external view returns (uint);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function balanceOf(address owner) external view returns (uint);
    function nonces(address owner) external view returns (uint);
    function factory() external view returns (address);
}

interface IUniswapV2Factory {
    function feeTo() external view returns (address);

}

// Uniswap V3 includes multiple "fee" pools (0.01%, 0.05%, 0.30%, and 1.00%)
// each one will have different amounts of liquidity, and different pool addresses

// For example (Arbitrum):
// The ETH/USDC pool address for 0.05% is 0xc31e54c7a869b9fcbecc14363cf510d1c41fa443
// The ETH/USDC pool address for 0.30% is 0x17c14D2c404D167802b16C450d3c99F88F2c4F4d
// The ETH/USDC pool address for 1.00% is 0x7e5E4a3F855f19cC1a45b9eFF1c8B2419036CE85;

// Pool Addresses need to be upgraded for the STAIK/USDC V3 Pools

//////////////////////////////////////////////////////////////////////////////////////

contract StaikDEXPoolInfoV1 is 
    // Initializable, 
    // OwnableUpgradeable {
    Ownable {

    /* 
    To account for any new V3 pools (or fees) set by Uniswap Governance, we have included 8x 
    // potential pools for future fees which can have the value set for them.

    // As of March 2023 there are 4x fee tiers - 0.01%, 0.05%, 0.30%, 1.00%
    // The 0.01% tier is usually reserved for stable pairs
    */

    // Currently set to Uniswap V3 ETH/USDC 0.05% pool for testing
    address public v3PoolAddress1 = 0xC31E54c7a869B9FcBEcc14363CF510d1c41fa443;

    // Currently set to Uniswap V3 ETH/USDC 0.30% pool for testing
    address public v3PoolAddress2 = 0x17c14D2c404D167802b16C450d3c99F88F2c4F4d;

    // Currently set to Uniswap V3 ETH/USDC 1.00% pool for testing
    address public v3PoolAddress3 = 0x7e5E4a3F855f19cC1a45b9eFF1c8B2419036CE85;

    // not set - not used
    address public v3PoolAddress4;

    // not set - not used
    address public v3PoolAddress5;

    // not set - not used
    address public v3PoolAddress6;

    // not set - not used
    address public v3PoolAddress7;

    // not set - not used
    address public v3PoolAddress8;

    /* 
    To account for any new V2 pairs (pools), we have included 8x 
    // potential pools for the future.
    */

    // Currently set to ETH/USDC Sushiswap V2 Pair for testing
    address public v2PoolAddress1 = 0x905dfCD5649217c42684f23958568e533C711Aa3;

    // not set - not used
    address public v2PoolAddress2;

    // not set - not used
    address public v2PoolAddress3;

    // not set - not used
    address public v2PoolAddress4;

    // not set - not used
    address public v2PoolAddress5;

    // not set - not used
    address public v2PoolAddress6;

    // not set - not used
    address public v2Poolddress7;

    // not set - not used
    address public v2PoolAddress8;



    // /// @custom:oz-upgrades-unsafe-allow constructor
    // constructor() {
    //     _disableInitializers();
    // }

    // function initialize() initializer public {
    //     __Ownable_init();
    // }



    // setter functions

        // update V3 pool addresses
    function updateV3PoolAddresses(
        address _poolAddress1,
        address _poolAddress2,
        address _poolAddress3
        // address _poolAddress4,
        // address _poolAddress5,
        // address _poolAddress6,
        // address _poolAddress7,
        // address _poolAddress8       
        ) public onlyOwner {
        v3PoolAddress1 = _poolAddress1;
        v3PoolAddress2 = _poolAddress2;
        v3PoolAddress3 = _poolAddress3;
        // v3PoolAddress4 = _poolAddress4;
        // v3PoolAddress5 = _poolAddress5;
        // v3PoolAddress6 = _poolAddress6;
        // v3PoolAddress7 = _poolAddress7;
        // v3PoolAddress8 = _poolAddress8;
    }

        // update V2 pool addresses
    function updateV2PoolAddresses(
        address _poolAddress1
        // address _poolAddress2,
        // address _poolAddress3
        // address _poolAddress4,
        // address _poolAddress5,
        // address _poolAddress6,
        // address _poolAddress7,
        // address _poolAddress8       
        ) public onlyOwner {
        v2PoolAddress1 = _poolAddress1;
        // v2PoolAddress2 = _poolAddress2;
        // v2PoolAddress3 = _poolAddress3;
        // v2PoolAddress4 = _poolAddress4;
        // v2PoolAddress5 = _poolAddress5;
        // v2PoolAddress6 = _poolAddress6;
        // v2PoolAddress7 = _poolAddress7;
        // v2PoolAddress8 = _poolAddress8;
    }


    // view functions

    function checkTokenInfoOfV3Pool(address _poolAddress) public view returns (
        string memory, string memory, uint8, string memory, string memory, uint8) {
        address poolAddress = _poolAddress;
        IUniswapV3PoolDerivedState pool = IUniswapV3PoolDerivedState(poolAddress);

        // Get the token Addresses of the two tokens in the pool
        address token0Address = pool.token0();
        address token1Address = pool.token1();

        string memory token0Name = IERC20(token0Address).name();
        string memory token1Name = IERC20(token1Address).name();
        string memory token0Symbol = IERC20(token0Address).symbol();
        string memory token1Symbol = IERC20(token1Address).symbol();
        uint8 token0Decimals = IERC20(token0Address).decimals();
        uint8 token1Decimals = IERC20(token1Address).decimals();

        // return the names, symbols, and decimals of token0 and token 1 respectively
        return (token0Name, token0Symbol, token0Decimals, token1Name, token1Symbol, token1Decimals);
    }

    function checkTokenInfoOfV2Pool(address _poolAddress) public view returns (
        string memory, string memory, uint8, string memory, string memory, uint8) {
        address poolAddress = _poolAddress;
        IUniswapV2Pair pool = IUniswapV2Pair(poolAddress);

        // Get the token Addresses of the two tokens in the pool
        address token0Address = pool.token0();
        address token1Address = pool.token1();

        string memory token0Name = IERC20(token0Address).name();
        string memory token1Name = IERC20(token1Address).name();
        string memory token0Symbol = IERC20(token0Address).symbol();
        string memory token1Symbol = IERC20(token1Address).symbol();
        uint8 token0Decimals = IERC20(token0Address).decimals();
        uint8 token1Decimals = IERC20(token1Address).decimals();

        // return the names, symbols, and decimals of token0 and token 1 respectively
        return (token0Name, token0Symbol, token0Decimals, token1Name, token1Symbol, token1Decimals);
    }


    function getTokenAddressesArrayV3Pools() public view returns (address[6] memory) {
        IUniswapV3PoolDerivedState pool1 = IUniswapV3PoolDerivedState(v3PoolAddress1);
        IUniswapV3PoolDerivedState pool2 = IUniswapV3PoolDerivedState(v3PoolAddress2);
        IUniswapV3PoolDerivedState pool3 = IUniswapV3PoolDerivedState(v3PoolAddress3);
        // IUniswapV3PoolDerivedState pool4 = IUniswapV3PoolDerivedState(v3PoolAddress4);
        // IUniswapV3PoolDerivedState pool5 = IUniswapV3PoolDerivedState(v3PoolAddress5);
        // IUniswapV3PoolDerivedState pool6 = IUniswapV3PoolDerivedState(v3PoolAddress6);
        // IUniswapV3PoolDerivedState pool7 = IUniswapV3PoolDerivedState(v3PoolAddress7);
        // IUniswapV3PoolDerivedState pool8 = IUniswapV3PoolDerivedState(v3PoolAddress8);

        return [
            pool1.token0(), pool1.token1(),         
            pool2.token0(), pool2.token1(),        
            pool3.token0(), pool3.token1()         
            // pool4.token0(), pool4.token1(),     
            // pool5.token0(), pool5.token1(),         
            // pool6.token0(), pool6.token1(),        
            // pool7.token0(), pool7.token1(),         
            // pool8.token0(), pool8.token1()    
        ];
    }

    function getTokenAddressesArrayV2Pools() public view returns (address[2] memory) {
        IUniswapV2Pair pool1 = IUniswapV2Pair(v2PoolAddress1);
        // IUniswapV2Pair pool2 = IUniswapV2Pair(v2PoolAddress2;
        // IUniswapV2Pair pool3 = IUniswapV2Pair(v2PoolAddress3);
        // IUniswapV2Pair pool4 = IUniswapV2Pair(v2PoolAddress4);
        // IUniswapV2Pair pool5 = IUniswapV2Pair(v2PoolAddress5);
        // IUniswapV2Pair pool6 = IUniswapV2Pair(v2PoolAddress6);
        // IUniswapV2Pair pool7 = IUniswapV2Pair(v2PoolAddress7);
        // IUniswapV2Pair pool8 = IUniswapV2Pair(v2PoolAddress8);

        return [
            pool1.token0(), pool1.token1()         
            // pool2.token0(), pool2.token1(),        
            // pool3.token0(), pool3.token1(),       
            // pool4.token0(), pool4.token1(),     
            // pool5.token0(), pool5.token1(),         
            // pool6.token0(), pool6.token1(),        
            // pool7.token0(), pool7.token1(),         
            // pool8.token0(), pool8.token1()    
        ];
    }


    // returns the Uniswap V3 pool fee for each pool
    function getV3PoolFees() public view returns (uint24[3] memory) {
        IUniswapV3PoolDerivedState pool1 = IUniswapV3PoolDerivedState(v3PoolAddress1);
        IUniswapV3PoolDerivedState pool2 = IUniswapV3PoolDerivedState(v3PoolAddress2);
        IUniswapV3PoolDerivedState pool3 = IUniswapV3PoolDerivedState(v3PoolAddress3);
        // IUniswapV3PoolDerivedState pool4 = IUniswapV3PoolDerivedState(v3PoolAddress4);
        // IUniswapV3PoolDerivedState pool5 = IUniswapV3PoolDerivedState(v3PoolAddress5);
        // IUniswapV3PoolDerivedState pool6 = IUniswapV3PoolDerivedState(v3PoolAddress6);
        // IUniswapV3PoolDerivedState pool7 = IUniswapV3PoolDerivedState(v3PoolAddress7);
        // IUniswapV3PoolDerivedState pool8 = IUniswapV3PoolDerivedState(v3PoolAddress8);
        return [
            pool1.fee(), 
            pool2.fee(),
            pool3.fee()
            // pool4.fee(),
            // pool5.fee(), 
            // pool6.fee(),
            // pool7.fee(), 
            // pool8.fee()
        ];
    }



    function getTokenAddressesFromV3Pool(address _poolAddress) public view returns (address, address) {
        address poolAddress = _poolAddress;
        IUniswapV3PoolDerivedState pool = IUniswapV3PoolDerivedState(poolAddress);

        // Get the token Addresses of the two tokens in the pool
        address token0Address = pool.token0();
        address token1Address = pool.token1();

        // return the addresses of token0 and token 1 respectively
        return (token0Address, token1Address);
    }

    function getTokenAddressesFromV2Pool(address _poolAddress) public view returns (address, address) {
        address poolAddress = _poolAddress;
        IUniswapV2Pair pool = IUniswapV2Pair(poolAddress);

        // Get the token Addresses of the two tokens in the pool
        address token0Address = pool.token0();
        address token1Address = pool.token1();

        // return the addresses of token0 and token 1 respectively
        return (token0Address, token1Address);
    }


    function getTokenBalancesFromV3Pool(address _poolAddress) public view returns (uint256, uint256) {
        (address token0Address, ) = getTokenAddressesFromV3Pool(_poolAddress);
        (, address token1Address) = getTokenAddressesFromV3Pool(_poolAddress);

        // Get the token Addresses of the two tokens in the pool
        IERC20 token0 = IERC20(token0Address);
        IERC20 token1 = IERC20(token1Address);

        uint256 balanceToken0 = token0.balanceOf(_poolAddress);
        uint256 balanceToken1 = token1.balanceOf(_poolAddress);

        // Return token balance for token0 and token 1 respectively
        return (balanceToken0, balanceToken1);
    }

    function getTokenBalancesFromV2Pool(address _poolAddress) public view returns (uint256, uint256) {
        (address token0Address, ) = getTokenAddressesFromV3Pool(_poolAddress);
        (, address token1Address) = getTokenAddressesFromV3Pool(_poolAddress);

        // Get the token Addresses of the two tokens in the pool
        IERC20 token0 = IERC20(token0Address);
        IERC20 token1 = IERC20(token1Address);

        uint256 balanceToken0 = token0.balanceOf(_poolAddress);
        uint256 balanceToken1 = token1.balanceOf(_poolAddress);

        // Return token balance for token0 and token 1 respectively
        return (balanceToken0, balanceToken1);
    }

}
