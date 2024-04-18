/**
 *Submitted for verification at BscScan.com on 2024-04-11
*/

// Sources flattened with hardhat v2.19.4 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/Context.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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


// File @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol@v0.8.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}


// File contracts/token.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;


abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}


interface IToken {
    function transfer(address _to, uint256 _amount) external;
    function balanceOf(address _who) external returns(uint256);
}

// Address for interfaces, diferent pairs= https://docs.chain.link/data-feeds/price-feeds/addresses/
// token = 0x7B934F688A55703913A35821a7cA758de62C074B
//treasure
contract Ito is Ownable, ReentrancyGuard{
    AggregatorV3Interface internal precioBnb;
    address constant goerliAggrAddr = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;
    uint256 public tokenPriceInUSD; // 8 decimales
    IToken public token;
    IToken public wrongToken;
    address payable treasure;
    uint256 public maxBuyDefault;
    int256 public multiplier;
    int256 public divisor;
    mapping (address => uint256) public maxBuy;
    mapping (address => uint256) private QuantityBought;

// hedgecoin = 0xF5c1aCA871F55379f2EF16538d7A55dE7eBD12bd
// owner = 0x7C7096D2005196717665197c23BA1bC34B816BA9
    constructor(address _account, address _token) Ownable(_account){
        precioBnb = AggregatorV3Interface(goerliAggrAddr);
        token = IToken(_token);
        treasure = payable (_account);
        tokenPriceInUSD = 1 ;
        multiplier = 1;
        divisor = 1;
        maxBuyDefault=10000000000000000000000;
    }

    function setMultiplier(int256 _multiplier) external onlyOwner {
        multiplier = _multiplier;
    }

    function setdivisor(int256 _divisor) external onlyOwner {
        divisor = _divisor;
    }

    function setMaxBuyDefault(uint256 _maxBuy) external onlyOwner {
        maxBuyDefault = _maxBuy;
    }

    function setMaxBuy(address _addr, uint256 _maxBuy) external onlyOwner {
        maxBuy[_addr] = _maxBuy;
    }

    function setTreasure(address payable _treasure) external onlyOwner {
        treasure = _treasure;
    }

    function setToken(address _token) external onlyOwner {
        token = IToken(_token);
    }

    function setWrongToken(address _wrongToken) external onlyOwner {
        wrongToken = IToken(_wrongToken);
    }

    function withdraw() external onlyOwner {
        wrongToken.transfer(owner(), wrongToken.balanceOf(address(this)));
    }

    function withdrawBNB() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function lastPriceBNB() public view returns (uint256){
        (, int256 answer, , , ) = precioBnb.latestRoundData();
        answer = answer * multiplier / divisor;
        return uint256(answer);
    }

    function setTokenPriceInUSD(uint256 _tokenPriceInUSD) external onlyOwner {
        tokenPriceInUSD = _tokenPriceInUSD;
    }

    function calculateMaxAmount(address _addr) public view returns(uint256) {
        if(maxBuy[_addr]==0) {
            return (maxBuyDefault - QuantityBought[_addr]);
        }else {  
            return (maxBuy[_addr] - QuantityBought[_addr]);
        }
    }

    function calculateTokenQuantity(uint256 _bnbAmount) public view returns(uint256 _quantity) {
        uint256 tokenAmountToGive = ((_bnbAmount * lastPriceBNB())/tokenPriceInUSD) / 10**8;
        if( tokenAmountToGive > calculateMaxAmount(msg.sender) ) {
            tokenAmountToGive = calculateMaxAmount(msg.sender);
        }
        return (tokenAmountToGive);
    }

    function price() public view returns (uint256){
        return ((1 * lastPriceBNB())/tokenPriceInUSD) / 10**8;
    }

    function buy() public payable nonReentrant() {
        uint256  _bnbAmount = msg.value;
        uint256 tokenAmountToGive = calculateTokenQuantity(_bnbAmount);
        if(tokenAmountToGive == calculateMaxAmount(msg.sender) ) {
            _bnbAmount = ((calculateMaxAmount(msg.sender) * 10**8)*tokenPriceInUSD) / lastPriceBNB() ;
            uint256 _bnbBack = msg.value - _bnbAmount;
            treasure.transfer(_bnbAmount);
            payable(msg.sender).transfer(_bnbBack);
        } else {
            treasure.transfer(_bnbAmount);
        }
        QuantityBought[_msgSender()] += tokenAmountToGive;
        token.transfer(_msgSender(), tokenAmountToGive);
    }

    function testBuy(uint256 _bnbAmount) public view returns(uint256 tokens, uint256 change, uint256 treasury) {
        uint256 tokenAmountToGive = calculateTokenQuantity(_bnbAmount);
        if(tokenAmountToGive == calculateMaxAmount(msg.sender)) {
            uint256 _bnbAmountToUse = ((calculateMaxAmount(msg.sender) * 10**8)*tokenPriceInUSD) / lastPriceBNB() ;
            change = _bnbAmount - _bnbAmountToUse;
            treasury=_bnbAmountToUse;
        } else {
            treasury = _bnbAmount;
        }
        tokens = tokenAmountToGive;
        return(tokens, change, treasury);
    }

    receive() external payable { 
        buy();
    }

}