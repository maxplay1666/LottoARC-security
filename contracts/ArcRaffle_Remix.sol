// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 ^0.8.20;

// contracts/interfaces/IArcRaffleVRF.sol

/// @dev D20 SDK 0.6.2 ID20VRF raw request and fee signatures.
// Source: https://registry.npmjs.org/@d20dao/vrf-sdk/-/vrf-sdk-0.6.2.tgz
interface IArcRaffleVRF {
    function quoteFee(uint32 callbackGasLimit) external view returns (uint256);
    function quoteFeeAt(uint32 callbackGasLimit, uint256 baseFee) external view returns (uint256);
    function requestRandomness(bytes32 clientSeed, uint32 callbackGasLimit, address refundAddress)
        external payable returns (uint256 requestId);
}

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// lib/openzeppelin-contracts/contracts/utils/StorageSlot.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.sol.eta.

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC-1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     // Define the slot. Alternatively, use the SlotDerivation library to derive the slot.
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * TIP: Consider using this library along with {SlotDerivation}.
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct Int256Slot {
        int256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Int256Slot` with member `value` located at `slot`.
     */
    function getInt256Slot(bytes32 slot) internal pure returns (Int256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns a `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }
}

// lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v5.5.0) (utils/ReentrancyGuard.sol)

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 *
 * IMPORTANT: Deprecated. This storage-based reentrancy guard will be removed and replaced
 * by the {ReentrancyGuardTransient} variant in v6.0.
 *
 * @custom:stateless
 */
abstract contract ReentrancyGuard {
    using StorageSlot for bytes32;

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant REENTRANCY_GUARD_STORAGE =
        0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00;

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _reentrancyGuardStorageSlot().getUint256Slot().value = NOT_ENTERED;
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

    /**
     * @dev A `view` only version of {nonReentrant}. Use to block view functions
     * from being called, preventing reading from inconsistent contract state.
     *
     * CAUTION: This is a "view" modifier and does not change the reentrancy
     * status. Use it only on view functions. For payable or non-payable functions,
     * use the standard {nonReentrant} modifier instead.
     */
    modifier nonReentrantView() {
        _nonReentrantBeforeView();
        _;
    }

    function _nonReentrantBeforeView() private view {
        if (_reentrancyGuardEntered()) {
            revert ReentrancyGuardReentrantCall();
        }
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        _nonReentrantBeforeView();

        // Any calls to nonReentrant after this point will fail
        _reentrancyGuardStorageSlot().getUint256Slot().value = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _reentrancyGuardStorageSlot().getUint256Slot().value = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _reentrancyGuardStorageSlot().getUint256Slot().value == ENTERED;
    }

    function _reentrancyGuardStorageSlot() internal pure virtual returns (bytes32) {
        return REENTRANCY_GUARD_STORAGE;
    }
}

// contracts/ArcRaffle.sol

contract ArcRaffle is ReentrancyGuard {
    uint256 public constant CONTRACT_VERSION = 6;
    address public constant ARC_MAINNET_VRF = 0xd20da057469C45928912d983F45790C41e290571;
    address public constant ARC_TESTNET_VRF = 0xd20DA0FF9087d053f0291524Eac12abA1ADBd945;
    IArcRaffleVRF public immutable vrfCoordinator;
    uint32 public constant CALLBACK_GAS_LIMIT = 150_000;
    uint256 public constant VRF_FUNDING_GRACE = 1 days;
    struct DrawState {
        uint256 requestId;
        uint256 reserve;
        uint256 feePaid;
        bytes32 randomness;
        bool ready;
        bool failed;
    }
    mapping(uint256 => DrawState) public draws;
    mapping(uint256 => uint256) public requestPoolId;
    mapping(address => uint256) public pendingVRFRefunds;
    uint256 public totalNativeLiabilities;
    IERC20 public constant USDC = IERC20(0x3600000000000000000000000000000000000000);

    enum PoolStatus {
        Open,
        DrawScheduled,
        Closed,
        Cancelled
    }

    enum DurationPreset {
        FifteenMinutes,
        ThirtyMinutes,
        OneHour,
        TwentyFourHours,
        SeventyTwoHours,
        Custom
    }

    struct Pool {
        uint256 poolId;
        address owner;
        uint256 maxTickets;
        uint256 entryFee;
        uint256 durationSeconds;
        uint256 createdAt;
        uint256 deadlineTimestamp;
        address[] tickets;
        uint256 drawBlock;
        uint256 commitDeadlineBlock;
        uint256 firstTicketTimestamp;
        uint256 autoDrawTimestamp;
        PoolStatus status;
    }

    uint256 public nextPoolId;
    mapping(uint256 => Pool) public pools;

    uint256[] public openPoolIds;
    mapping(uint256 => uint256) private _openPoolIndexPlusOne;

    uint256[] public allPoolIds;

    mapping(address => mapping(uint256 => bool)) private _walletPoolIndexed;
    mapping(address => uint256[]) private _playerPoolList;

    mapping(address => uint256) public pendingRefunds;
    uint256 public treasuryBalance;
    // Total active pools, including the exempt treasury creator.
    uint256 public activePoolCount;
    uint256 public publicActivePoolCount;
    mapping(address => uint256) public activePoolByCreator;

    address public immutable TREASURY = 0x3d2b1177305fF33E2384F3e059B9dDE10147ABD5;

    uint256 public constant POOL_OWNER_FEE_BPS = 500;
    uint256 public constant TREASURY_FEE_BPS = 93;
    uint256 private constant BPS_DENOMINATOR = 10_000;

    uint256 public constant MIN_DURATION = 900;
    uint256 public constant MAX_DURATION = 604800;
    uint256 public constant REVEAL_DELAY = 3;
    uint256 public constant AUTO_DRAW_GRACE = 900;
    uint256 public constant FULL_POOL_DRAW_DELAY = 600;

    uint256 public constant MIN_TICKETS = 2;
    uint256 public constant MAX_TICKETS_CAP = 100;
    uint256 public constant MAX_ACTIVE_POOLS = 20;
    uint256 public constant FRONTEND_PAGE_SIZE = 20;

    uint256 public constant PRESET_15_MIN = 15 minutes;
    uint256 public constant PRESET_30_MIN = 30 minutes;
    uint256 public constant PRESET_1_HOUR = 1 hours;
    uint256 public constant PRESET_24_HOURS = 24 hours;
    uint256 public constant PRESET_72_HOURS = 72 hours;

    event PoolCreated(
        uint256 indexed poolId,
        address indexed owner,
        uint256 maxTickets,
        uint256 entryFee,
        uint256 durationSeconds
    );
    event PoolEntered(uint256 indexed poolId, address indexed player, uint256 ticketIndex);
    event PoolFull(uint256 indexed poolId);
    event DrawScheduled(uint256 indexed poolId, uint256 drawBlock);
    event WinnerDrawn(uint256 indexed poolId, address indexed winner, uint256 winnerPayout, uint256 pot);
    event PoolCancelled(uint256 indexed poolId);
    event TreasuryClaimed(address indexed by, uint256 amount);
    event RefundClaimed(address indexed by, uint256 amount);
    event FeesAccrued(uint256 indexed poolId, address indexed creator, uint256 creatorFee, uint256 treasuryFee);
    event VRFFunded(uint256 indexed poolId, address indexed creator, uint256 amount);
    event RandomnessRequested(uint256 indexed poolId, uint256 indexed requestId, uint256 feePaid);
    event RandomnessReady(uint256 indexed poolId, uint256 indexed requestId, bytes32 word);
    event RandomnessFailed(uint256 indexed poolId, uint256 indexed requestId);
    event VRFRefundCredited(uint256 indexed poolId, address indexed creator, uint256 amount);
    event VRFRefundClaimed(address indexed creator, uint256 amount);
    event ClaimRecipient(address indexed account, address indexed recipient, uint256 amount, bool nativeUSDC);

    constructor(address coordinator) {
        if (block.chainid == 5042) require(coordinator == ARC_MAINNET_VRF, "Wrong VRF coordinator");
        else if (block.chainid == 5042002) require(coordinator == ARC_TESTNET_VRF, "Wrong VRF coordinator");
        else require(block.chainid == 31337, "Unsupported network");
        require(coordinator.code.length != 0, "Invalid VRF coordinator");
        vrfCoordinator = IArcRaffleVRF(coordinator);
        nextPoolId = 1;
    }

    function createPool(uint256 maxTickets, uint256 entryFee, uint256 durationSeconds) external payable nonReentrant {
        _createPool(maxTickets, entryFee, durationSeconds);
    }

    function createPoolWithPreset(
        uint256 maxTickets,
        uint256 entryFee,
        DurationPreset preset,
        uint256 customDurationSeconds
    ) external payable nonReentrant {
        uint256 durationSeconds = _resolveDuration(preset, customDurationSeconds);
        _createPool(maxTickets, entryFee, durationSeconds);
    }

    function enterPool(uint256 poolId) external nonReentrant {
        _enterPool(poolId, 1);
    }

    function enterPool(uint256 poolId, uint256 qty) external nonReentrant {
        _enterPool(poolId, qty);
    }

    function scheduleDraw(uint256 poolId) external nonReentrant {
        require(_poolExists(poolId), "Pool does not exist");

        Pool storage pool = pools[poolId];
        require(pool.status == PoolStatus.Open, "Pool not open");
        require(pool.drawBlock == 0, "Draw already scheduled");
        require(pool.autoDrawTimestamp == 0, "Auto draw pending");
        require(block.timestamp > pool.deadlineTimestamp, "Pool deadline not reached");
        require(pool.tickets.length >= 2, "Need at least 2 tickets");
        require(pool.tickets.length < pool.maxTickets, "Pool full uses auto draw");

        _scheduleDraw(poolId);
    }

    function executeDraw(uint256 poolId) external nonReentrant {
        require(_poolExists(poolId), "Pool does not exist");

        Pool storage pool = pools[poolId];
        uint256 ticketCount = pool.tickets.length;
        require(ticketCount >= 2, "Need at least 2 tickets");

        DrawState storage draw = draws[poolId];
        if (pool.status == PoolStatus.Open) {
            require(pool.autoDrawTimestamp > 0, "No draw path");
            require(block.timestamp >= pool.autoDrawTimestamp, "Auto draw countdown active");
            require(block.timestamp <= pool.autoDrawTimestamp + AUTO_DRAW_GRACE, "Auto draw expired");
            require(ticketCount == pool.maxTickets, "Pool not full");
            _scheduleDraw(poolId);
            return;
        }
        require(pool.status == PoolStatus.DrawScheduled, "Draw not scheduled");
        require(draw.ready && !draw.failed, "Randomness not ready");
        uint256 random = uint256(draw.randomness);
        uint256 pot = ticketCount * pool.entryFee;
        uint256 poolOwnerFee = (pot * POOL_OWNER_FEE_BPS) / BPS_DENOMINATOR;
        uint256 treasuryFee = (pot * TREASURY_FEE_BPS) / BPS_DENOMINATOR;
        uint256 winnerPayout = pot - poolOwnerFee - treasuryFee;

        address winner = pool.tickets[random % ticketCount];

        pool.status = PoolStatus.Closed;
        pool.autoDrawTimestamp = 0;

        treasuryBalance += treasuryFee;
        pendingRefunds[pool.owner] += poolOwnerFee;
        pendingRefunds[winner] += winnerPayout;
        _creditVRFReserve(poolId);
        _releaseCreatorSlot(pool.owner);

        _removeFromOpenPools(poolId);

        emit WinnerDrawn(poolId, winner, winnerPayout, pot);
        emit FeesAccrued(poolId, pool.owner, poolOwnerFee, treasuryFee);
    }

    function cancelPool(uint256 poolId) external nonReentrant {
        require(_poolExists(poolId), "Pool does not exist");

        Pool storage pool = pools[poolId];
        require(msg.sender == pool.owner, "Not pool owner");
        require(pool.status == PoolStatus.Open, "Pool not open");
        require(pool.autoDrawTimestamp == 0, "Auto draw pending");

        require(pool.tickets.length == 0, "Funded pool cannot be cancelled by owner");

        _accruePoolRefunds(poolId);

        pool.status = PoolStatus.Cancelled;
        _creditVRFReserve(poolId);
        _releaseCreatorSlot(pool.owner);
        _removeFromOpenPools(poolId);

        emit PoolCancelled(poolId);
    }

    function cancelStalePool(uint256 poolId) external nonReentrant {
        require(_poolExists(poolId), "Pool does not exist");

        Pool storage pool = pools[poolId];
        require(pool.status == PoolStatus.Open, "Pool not open");
        require(pool.autoDrawTimestamp == 0, "Use cancelExpiredAutoDraw");
        require(pool.drawBlock == 0, "Draw already scheduled");
        require(block.timestamp > pool.deadlineTimestamp, "Pool not expired");
        require(pool.tickets.length < 2, "Funded pool must draw");

        _accruePoolRefunds(poolId);

        pool.status = PoolStatus.Cancelled;
        _creditVRFReserve(poolId);
        _releaseCreatorSlot(pool.owner);
        _removeFromOpenPools(poolId);

        emit PoolCancelled(poolId);
    }

    function cancelExpiredDraw(uint256 poolId) external nonReentrant {
        require(_poolExists(poolId), "Pool does not exist");

        Pool storage pool = pools[poolId];
        require(pool.status == PoolStatus.DrawScheduled, "Draw not scheduled");
        require(draws[poolId].failed && !draws[poolId].ready, "VRF failure not confirmed");

        _accruePoolRefunds(poolId);

        pool.status = PoolStatus.Cancelled;
        _creditVRFReserve(poolId);
        _releaseCreatorSlot(pool.owner);
        _removeFromOpenPools(poolId);

        emit PoolCancelled(poolId);
    }

    function cancelExpiredAutoDraw(uint256 poolId) external nonReentrant {
        require(_poolExists(poolId), "Pool does not exist");

        Pool storage pool = pools[poolId];
        require(pool.status == PoolStatus.Open, "Pool not open");
        require(pool.autoDrawTimestamp > 0, "Auto draw not set");
        require(block.timestamp > pool.autoDrawTimestamp + AUTO_DRAW_GRACE, "Auto draw not expired");

        _accruePoolRefunds(poolId);

        pool.status = PoolStatus.Cancelled;
        _creditVRFReserve(poolId);
        _releaseCreatorSlot(pool.owner);
        _removeFromOpenPools(poolId);

        emit PoolCancelled(poolId);
    }

    function claimRefund() external nonReentrant {
        _claimRefund(msg.sender);
    }

    /// @notice Only the credit owner may redirect its own claim (e.g. a rejecting smart wallet).
    function claimRefundTo(address recipient) external nonReentrant {
        _claimRefund(recipient);
    }

    function _claimRefund(address recipient) internal {
        require(recipient != address(0) && recipient != address(this), "Invalid claim recipient");
        uint256 amount = pendingRefunds[msg.sender];
        require(amount > 0, "No refund available");

        pendingRefunds[msg.sender] = 0;

        bool refunded = USDC.transfer(recipient, amount);
        require(refunded, "Refund transfer failed");
        emit RefundClaimed(msg.sender, amount);
        emit ClaimRecipient(msg.sender, recipient, amount, false);
    }

    function claimTreasury() external nonReentrant {
        require(msg.sender == TREASURY, "Not treasury");

        uint256 amount = treasuryBalance;
        require(amount > 0, "Nothing to claim");

        treasuryBalance = 0;

        bool ok = USDC.transfer(TREASURY, amount);
        require(ok, "Transfer failed");

        emit TreasuryClaimed(TREASURY, amount);
    }

    function getPoolTickets(uint256 poolId) external view returns (address[] memory) {
        require(_poolExists(poolId), "Pool does not exist");
        return pools[poolId].tickets;
    }

    function getPoolPot(uint256 poolId) external view returns (uint256) {
        require(_poolExists(poolId), "Pool does not exist");

        Pool storage pool = pools[poolId];
        return pool.tickets.length * pool.entryFee;
    }

    function getOpenPools() external view returns (uint256[] memory) {
        return openPoolIds;
    }

    /// @notice Includes pending draws; bounded discovery for exempt unlimited creators.
    function getActivePools(uint256 offset, uint256 limit) external view returns (uint256[] memory ids) {
        uint256 total = openPoolIds.length;
        if (offset >= total || limit == 0) return new uint256[](0);
        uint256 count = limit > FRONTEND_PAGE_SIZE ? FRONTEND_PAGE_SIZE : limit;
        if (count > total - offset) count = total - offset;
        ids = new uint256[](count);
        for (uint256 i; i < count; i++) ids[i] = openPoolIds[total - 1 - offset - i];
    }

    function getAllPools(uint256 offset, uint256 limit) external view returns (uint256[] memory) {
        if (limit == 0) {
            return new uint256[](0);
        }

        uint256 total = allPoolIds.length;
        if (offset >= total) {
            return new uint256[](0);
        }

        uint256 cappedLimit = limit;
        if (cappedLimit > FRONTEND_PAGE_SIZE) {
            cappedLimit = FRONTEND_PAGE_SIZE;
        }

        uint256 remaining = total - offset;
        uint256 count = cappedLimit < remaining ? cappedLimit : remaining;

        uint256[] memory ids = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            ids[i] = allPoolIds[total - 1 - (offset + i)];
        }

        return ids;
    }

    function getMyPools(address player, uint256 offset, uint256 limit) external view returns (uint256[] memory) {
        if (limit == 0) {
            return new uint256[](0);
        }

        uint256 cappedLimit = limit;
        if (cappedLimit > FRONTEND_PAGE_SIZE) {
            cappedLimit = FRONTEND_PAGE_SIZE;
        }

        uint256[] storage playerPools = _playerPoolList[player];
        uint256 total = playerPools.length;
        if (offset >= total) {
            return new uint256[](0);
        }

        uint256 remaining = total - offset;
        uint256 count = cappedLimit < remaining ? cappedLimit : remaining;

        uint256[] memory ids = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            ids[i] = playerPools[total - 1 - (offset + i)];
        }

        return ids;
    }

    function getPool(uint256 poolId) external view returns (Pool memory) {
        require(_poolExists(poolId), "Pool does not exist");
        return pools[poolId];
    }

    function isTimedOut(uint256 poolId) external view returns (bool) {
        require(_poolExists(poolId), "Pool does not exist");

        Pool storage pool = pools[poolId];
        return
            pool.status == PoolStatus.Open &&
            block.timestamp > pool.deadlineTimestamp &&
            pool.tickets.length < pool.maxTickets;
    }

    function _createPool(uint256 maxTickets, uint256 entryFee, uint256 durationSeconds) internal {
        require(msg.value >= vrfCoordinator.quoteFee(CALLBACK_GAS_LIMIT), "VRF reserve insufficient");
        bool exempt = msg.sender == TREASURY;
        if (!exempt) {
            require(publicActivePoolCount < MAX_ACTIVE_POOLS, "Max active pools reached");
            require(activePoolByCreator[msg.sender] == 0, "Creator already has active pool");
        }
        require(maxTickets >= MIN_TICKETS && maxTickets <= MAX_TICKETS_CAP, "Invalid max tickets");
        require(entryFee >= 1_000_000, "Entry fee too low");
        // Ensure even a full pool and fee multiplications cannot overflow.
        require(entryFee <= type(uint256).max / MAX_TICKETS_CAP / BPS_DENOMINATOR, "Entry fee too high");
        require(durationSeconds >= MIN_DURATION && durationSeconds <= MAX_DURATION, "Invalid duration");

        uint256 poolId = nextPoolId;
        nextPoolId = poolId + 1;

        Pool storage pool = pools[poolId];
        pool.poolId = poolId;
        pool.owner = msg.sender;
        pool.maxTickets = maxTickets;
        pool.entryFee = entryFee;
        pool.durationSeconds = durationSeconds;
        pool.createdAt = block.timestamp;
        pool.deadlineTimestamp = block.timestamp + durationSeconds;
        pool.status = PoolStatus.Open;
        activePoolCount += 1;
        if (!exempt) {
            publicActivePoolCount += 1;
            activePoolByCreator[msg.sender] = poolId;
        }

        _openPoolIndexPlusOne[poolId] = openPoolIds.length + 1;
        openPoolIds.push(poolId);
        allPoolIds.push(poolId);

        if (!_walletPoolIndexed[msg.sender][poolId]) {
            _walletPoolIndexed[msg.sender][poolId] = true;
            _playerPoolList[msg.sender].push(poolId);
        }

        draws[poolId].reserve = msg.value;
        totalNativeLiabilities += msg.value;
        emit VRFFunded(poolId, msg.sender, msg.value);
        emit PoolCreated(poolId, msg.sender, maxTickets, entryFee, durationSeconds);
        // Atomic creation + first ticket: failed payment rolls back the entire pool.
        if (!exempt) _enterPool(poolId, 1);
    }

    function _enterPool(uint256 poolId, uint256 qty) internal {
        require(_poolExists(poolId), "Pool does not exist");
        require(qty >= 1, "Invalid quantity");

        Pool storage pool = pools[poolId];
        require(pool.status == PoolStatus.Open, "Pool not open");
        require(pool.drawBlock == 0, "Draw already scheduled");
        require(block.timestamp <= pool.deadlineTimestamp, "Pool deadline passed");

        uint256 ticketCount = pool.tickets.length;
        require(ticketCount < pool.maxTickets, "Pool full");

        uint256 remaining = pool.maxTickets - ticketCount;
        require(qty <= remaining, "Quantity exceeds remaining slots");

        // ── Effects (all state changes BEFORE external call) ────────────────
        if (ticketCount == 0) {
            pool.firstTicketTimestamp = block.timestamp;
        }

        for (uint256 i = 0; i < qty; i++) {
            pool.tickets.push(msg.sender);
            emit PoolEntered(poolId, msg.sender, ticketCount + i);
        }

        if (!_walletPoolIndexed[msg.sender][poolId]) {
            _walletPoolIndexed[msg.sender][poolId] = true;
            _playerPoolList[msg.sender].push(poolId);
        }

        bool isFull = pool.tickets.length == pool.maxTickets;
        if (isFull) {
            pool.autoDrawTimestamp = block.timestamp + FULL_POOL_DRAW_DELAY;
            emit PoolFull(poolId);
        }

        uint256 totalCost = pool.entryFee * qty;

        // ── Interaction (external call LAST) ────────────────────────────────
        uint256 balanceBefore = USDC.balanceOf(address(this));
        bool pulled = USDC.transferFrom(msg.sender, address(this), totalCost);
        require(pulled, "USDC transfer failed");
        require(USDC.balanceOf(address(this)) - balanceBefore == totalCost, "Incorrect USDC received");
    }

    function _releaseCreatorSlot(address creator) internal {
        activePoolCount -= 1;
        if (creator != TREASURY) {
            publicActivePoolCount -= 1;
            delete activePoolByCreator[creator];
        }
    }

    function _scheduleDraw(uint256 poolId) internal {
        Pool storage pool = pools[poolId];
        DrawState storage draw = draws[poolId];
        require(draw.requestId == 0, "Draw already scheduled");
        // Before any request, the funding window is exclusive with cancellation.
        uint256 readyAt = pool.autoDrawTimestamp > 0 ? pool.autoDrawTimestamp : pool.deadlineTimestamp;
        require(block.timestamp <= readyAt + VRF_FUNDING_GRACE, "VRF funding window expired");
        uint256 fee = vrfCoordinator.quoteFee(CALLBACK_GAS_LIMIT);
        require(fee <= draw.reserve, "VRF reserve insufficient");
        pool.status = PoolStatus.DrawScheduled;
        pool.autoDrawTimestamp = 0;
        draw.reserve -= fee;
        draw.feePaid = fee;
        totalNativeLiabilities -= fee;
        bytes32 seed = keccak256(abi.encode(block.chainid, address(this), poolId, pool.tickets));
        uint256 requestId = vrfCoordinator.requestRandomness{value: fee}(seed, CALLBACK_GAS_LIMIT, pool.owner);
        require(requestId != 0 && requestPoolId[requestId] == 0, "Invalid VRF request ID");
        draw.requestId = requestId;
        requestPoolId[requestId] = poolId;
        // Keep pending draws discoverable until settlement or cancellation.
        _creditVRFReserve(poolId);
        emit DrawScheduled(poolId, 0); // Legacy event; no blockhash deadline remains.
        emit RandomnessRequested(poolId, requestId, fee);
    }

    function _creditVRFReserve(uint256 poolId) internal {
        uint256 amount = draws[poolId].reserve;
        if (amount == 0) return;
        draws[poolId].reserve = 0;
        pendingVRFRefunds[pools[poolId].owner] += amount;
        emit VRFRefundCredited(poolId, pools[poolId].owner, amount);
    }

    function quoteVRFReserve(uint256 baseFee) external view returns (uint256) {
        return vrfCoordinator.quoteFeeAt(CALLBACK_GAS_LIMIT, baseFee);
    }

    function topUpVRF(uint256 poolId) external payable nonReentrant {
        require(_poolExists(poolId), "Pool does not exist");
        require(msg.sender == pools[poolId].owner, "Not pool owner");
        require(pools[poolId].status == PoolStatus.Open, "Pool not open");
        require(msg.value > 0, "Empty VRF top up");
        draws[poolId].reserve += msg.value;
        totalNativeLiabilities += msg.value;
        emit VRFFunded(poolId, msg.sender, msg.value);
    }

    function claimVRFRefund() external nonReentrant {
        _claimVRFRefund(msg.sender);
    }

    function claimVRFRefundTo(address payable recipient) external nonReentrant {
        _claimVRFRefund(recipient);
    }

    function _claimVRFRefund(address recipient) internal {
        require(recipient != address(0) && recipient != address(this), "Invalid claim recipient");
        uint256 amount = pendingVRFRefunds[msg.sender];
        require(amount > 0, "No VRF refund available");
        pendingVRFRefunds[msg.sender] = 0;
        totalNativeLiabilities -= amount;
        (bool ok,) = payable(recipient).call{value: amount}("");
        require(ok, "VRF refund transfer failed");
        emit VRFRefundClaimed(msg.sender, amount);
        emit ClaimRecipient(msg.sender, recipient, amount, true);
    }

    function rawFulfillRandomness(uint256 requestId, bytes32 word) external nonReentrant {
        require(msg.sender == address(vrfCoordinator), "Not VRF coordinator");
        uint256 poolId = requestPoolId[requestId];
        require(poolId != 0, "Unknown VRF request");
        DrawState storage draw = draws[poolId];
        require(!draw.ready && !draw.failed && pools[poolId].status == PoolStatus.DrawScheduled, "VRF request completed");
        draw.randomness = word;
        draw.ready = true;
        emit RandomnessReady(poolId, requestId, word);
    }

    // D20 notifies only after an unfulfilled request has been terminally refunded
    // or credited to its fixed recipient. Fees go directly to the creator, not here.
    // No reroll is permitted. Delivery-failed-but-accepted proofs must be retried
    // on the coordinator, not refunded by this consumer.
    function onRefund(uint256 requestId) external nonReentrant {
        require(msg.sender == address(vrfCoordinator), "Not VRF coordinator");
        uint256 poolId = requestPoolId[requestId];
        require(poolId != 0, "Unknown VRF request");
        DrawState storage draw = draws[poolId];
        require(!draw.ready && !draw.failed && pools[poolId].status == PoolStatus.DrawScheduled, "VRF request completed");
        draw.failed = true;
        emit RandomnessFailed(poolId, requestId);
    }

    function cancelUnfundedDraw(uint256 poolId) external nonReentrant {
        require(_poolExists(poolId), "Pool does not exist");
        Pool storage pool = pools[poolId];
        require(pool.status == PoolStatus.Open, "Pool not open");
        require(pool.autoDrawTimestamp == 0, "Use cancelExpiredAutoDraw");
        require(block.timestamp > pool.deadlineTimestamp + VRF_FUNDING_GRACE, "VRF funding window active");
        _accruePoolRefunds(poolId);
        pool.status = PoolStatus.Cancelled;
        _creditVRFReserve(poolId);
        _releaseCreatorSlot(pool.owner);
        _removeFromOpenPools(poolId);
        emit PoolCancelled(poolId);
    }
    function _resolveDuration(DurationPreset preset, uint256 customDurationSeconds) internal pure returns (uint256) {
        if (preset == DurationPreset.FifteenMinutes) {
            return PRESET_15_MIN;
        }
        if (preset == DurationPreset.ThirtyMinutes) {
            return PRESET_30_MIN;
        }
        if (preset == DurationPreset.OneHour) {
            return PRESET_1_HOUR;
        }
        if (preset == DurationPreset.TwentyFourHours) {
            return PRESET_24_HOURS;
        }
        if (preset == DurationPreset.SeventyTwoHours) {
            return PRESET_72_HOURS;
        }

        require(preset == DurationPreset.Custom, "Invalid preset");
        return customDurationSeconds;
    }

    function _accruePoolRefunds(uint256 poolId) internal {
        Pool storage pool = pools[poolId];
        uint256 ticketCount = pool.tickets.length;

        for (uint256 i = 0; i < ticketCount; i++) {
            pendingRefunds[pool.tickets[i]] += pool.entryFee;
        }
    }

    function _removeFromOpenPools(uint256 poolId) internal {
        uint256 indexPlusOne = _openPoolIndexPlusOne[poolId];
        if (indexPlusOne == 0) {
            return;
        }

        uint256 index = indexPlusOne - 1;
        uint256 lastIndex = openPoolIds.length - 1;

        if (index != lastIndex) {
            uint256 lastPoolId = openPoolIds[lastIndex];
            openPoolIds[index] = lastPoolId;
            _openPoolIndexPlusOne[lastPoolId] = index + 1;
        }

        openPoolIds.pop();
        delete _openPoolIndexPlusOne[poolId];
    }

    function _poolExists(uint256 poolId) internal view returns (bool) {
        return poolId > 0 && poolId < nextPoolId;
    }
}
