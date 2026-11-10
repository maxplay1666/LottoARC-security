// SPDX-License-Identifier: MIT
pragma solidity =0.8.28;

// contracts/vendor/d20/RandomnessMapping.sol

/// @notice Version 1 deterministic, unbiased range sampling and bounded game operations.
/// @dev Choice/shuffle outputs are indices. Consumers must lock their item list before requesting.
library RandomnessMapping {
    enum Operation { Raw, DiceRoll, CoinFlip, NumberRange, ChooseOne, ChooseMany, Shuffle }
    struct Spec {
        Operation operation;
        uint256 lower;
        uint256 upper;
        uint32 count;
        uint32 population;
    }
    struct Stream { bytes32 randomness; uint256 cursor; }
    bytes32 internal constant MAP_DOMAIN = keccak256("D20_MAP");
    uint32 internal constant MAX_ITEMS = 256;
    uint32 internal constant MAX_DICE = 128;
    error InvalidMapping();

    function validate(Spec memory s) internal pure {
        if (s.operation == Operation.Raw) {
            if (s.lower != 0 || s.upper != 0 || s.count != 0 || s.population != 0) revert InvalidMapping();
        } else if (s.operation == Operation.DiceRoll) {
            if (s.lower != 0 || s.upper < 2 || s.count == 0 || s.count > MAX_DICE || s.population != 0)
                revert InvalidMapping();
        } else if (s.operation == Operation.CoinFlip) {
            if (s.lower != 0 || s.upper != 0 || s.count != 1 || s.population != 0) revert InvalidMapping();
        } else if (s.operation == Operation.NumberRange) {
            if (s.lower > s.upper || s.count != 1 || s.population != 0) revert InvalidMapping();
        } else {
            if (s.lower != 0 || s.upper != 0 || s.population == 0 || s.population > MAX_ITEMS)
                revert InvalidMapping();
            if (s.operation == Operation.ChooseOne && s.count != 1) revert InvalidMapping();
            if (s.operation == Operation.ChooseMany && (s.count == 0 || s.count > s.population))
                revert InvalidMapping();
            if (s.operation == Operation.Shuffle && s.count != s.population) revert InvalidMapping();
        }
    }

    function hash(Spec memory s) internal pure returns (bytes32) {
        return keccak256(abi.encode(s.operation, s.lower, s.upper, s.count, s.population));
    }

    function map(bytes32 randomness, Spec memory s) internal pure returns (uint256[] memory result) {
        validate(s);
        Stream memory stream = Stream(randomness, 0);
        if (s.operation == Operation.Raw) {
            result = new uint256[](1);
            result[0] = uint256(randomness);
        } else if (s.operation == Operation.DiceRoll) {
            result = new uint256[](s.count);
            for (uint256 i; i < s.count; ++i) result[i] = sample(stream, s.upper) + 1;
        } else if (s.operation == Operation.CoinFlip) {
            result = new uint256[](1);
            result[0] = sample(stream, 2); // 0 = tails, 1 = heads.
        } else if (s.operation == Operation.NumberRange) {
            result = new uint256[](1);
            result[0] = s.lower == 0 && s.upper == type(uint256).max
                ? next(stream) : s.lower + sample(stream, s.upper - s.lower + 1);
        } else if (s.operation == Operation.ChooseOne) {
            result = new uint256[](1);
            result[0] = sample(stream, s.population);
        } else {
            // Partial Fisher-Yates: without-replacement choices, or a full permutation.
            uint256[] memory pool = new uint256[](s.population);
            for (uint256 i; i < s.population; ++i) pool[i] = i;
            result = new uint256[](s.count);
            for (uint256 i; i < s.count; ++i) {
                uint256 j = i + sample(stream, s.population - i);
                (pool[i], pool[j]) = (pool[j], pool[i]);
                result[i] = pool[i];
            }
        }
    }

    function next(Stream memory stream) internal pure returns (uint256) {
        return uint256(keccak256(abi.encode(MAP_DOMAIN, stream.randomness, stream.cursor++)));
    }

    /// @dev Reject the short residue prefix instead of introducing modulo bias.
    function sample(Stream memory stream, uint256 bound) internal pure returns (uint256) {
        uint256 threshold;
        unchecked { threshold = (0 - bound) % bound; }
        uint256 word;
        do { word = next(stream); } while (word < threshold);
        return word % bound;
    }
}

// contracts/PickACard.sol

interface IPickCardERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

abstract contract PickCardReentrancyGuard {
    uint256 private _locked = 1;
    error ReentrantCall();

    modifier nonReentrant() {
        if (_locked != 1) revert ReentrantCall();
        _locked = 2;
        _;
        _locked = 1;
    }
}

/// @dev Minimal interface for D20DAO VRF's mapped-randomness endpoint.
///      The production Arc Mainnet coordinator is supplied to the constructor.
interface IPickCardVRF {
    enum Operation {
        Raw,
        DiceRoll,
        CoinFlip,
        NumberRange,
        ChooseOne,
        ChooseMany,
        Shuffle
    }

    struct Spec {
        Operation operation;
        uint256 lower;
        uint256 upper;
        uint32 count;
        uint32 population;
    }

    function quoteFee(uint32 callbackGasLimit) external view returns (uint256);
    function quoteFeeAt(uint32 callbackGasLimit, uint256 baseFee) external view returns (uint256);
    function requestMappedRandomness(
        bytes32 clientSeed,
        uint32 callbackGasLimit,
        address refundAddress,
        Spec calldata spec
    ) external payable returns (uint256 requestId);
    function getMappedResult(uint256 requestId) external view returns (uint256[] memory);
}

/// @title Pick a Card
/// @notice Two-player USDC card pools. Cards are not selected until player two
///         has funded the pool. D20DAO VRF chooses two distinct ranks and both
///         cards are revealed together during settlement.
/// @dev Card values are 2..14, where J=11, Q=12, K=13 and A=14.
contract PickACard is PickCardReentrancyGuard {
    uint256 public constant CONTRACT_VERSION = 4;
    address public constant ARC_MAINNET_COORDINATOR = 0xd20da057469C45928912d983F45790C41e290571;
    IPickCardERC20 public constant USDC = IPickCardERC20(0x3600000000000000000000000000000000000000);
    address public constant TREASURY = 0x3d2b1177305fF33E2384F3e059B9dDE10147ABD5;

    uint256 public constant TREASURY_FEE_BPS = 93;
    uint256 public constant WINNER_BPS = 9_907;
    uint256 public constant BPS_DENOMINATOR = 10_000;
    uint256 public constant CANCEL_DELAY = 10 minutes;
    uint32 public constant CALLBACK_GAS_LIMIT = 100_000;

    enum PoolStatus {
        Open,
        Drawing,
        Settled,
        Cancelled
    }

    struct Pool {
        uint256 poolId;
        address creator;
        address opponent;
        uint256 stake;
        uint256 createdAt;
        uint256 joinedAt;
        uint256 requestId;
        uint8 creatorCard;
        uint8 opponentCard;
        address winner;
        uint256 winnerPayout;
        bool randomReady;
        PoolStatus status;
    }

    IPickCardVRF public immutable vrfCoordinator;
    uint256 public nextPoolId = 1;
    uint256 public treasuryBalance;
    bool public depositsPaused;
    mapping(uint256 => Pool) private _pools;
    mapping(uint256 => uint256) public requestPoolId;
    mapping(address => uint256) public pendingWithdrawals;
    mapping(uint256 => bool) private _usedRequestIds;
    mapping(uint256 => bytes32) public acceptedRandomness;

    uint256[] private _openPoolIds;
    mapping(uint256 => uint256) private _openPoolIndexPlusOne;
    uint256[] private _allPoolIds;
    mapping(address => uint256[]) private _playerPoolIds;

    event PoolCreated(uint256 indexed poolId, address indexed creator, uint256 stake);
    event PoolJoined(uint256 indexed poolId, address indexed opponent, uint256 requestId);
    event RandomnessRequested(uint256 indexed poolId, uint256 indexed requestId);
    event RandomnessReady(uint256 indexed poolId, uint256 indexed requestId);
    event RandomnessRefunded(uint256 indexed poolId, uint256 indexed requestId);
    event PoolSettled(
        uint256 indexed poolId,
        address indexed winner,
        uint8 creatorCard,
        uint8 opponentCard,
        uint256 winnerPayout,
        uint256 treasuryFee
    );
    event PoolCancelled(uint256 indexed poolId, address indexed creator, uint256 refund);
    event FailedDrawCancelled(uint256 indexed poolId, uint256 refundPerPlayer);
    event WithdrawalClaimed(address indexed account, uint256 amount);
    event TreasuryClaimed(address indexed treasury, uint256 amount);
    event DepositsPaused(bool paused);

    error InvalidCoordinator();
    error DepositsArePaused();
    error InvalidRequestId();
    error InvalidPage();
    error RetryWindowClosed();
    error PoolDoesNotExist();
    error InvalidStake();
    error PoolNotOpen();
    error CannotJoinOwnPool();
    error CancellationTooEarly();
    error NotCreator();
    error DrawNotReady();
    error DrawAlreadyRequested();
    error NotParticipant();
    error UnexpectedCallback();
    error InvalidCards();
    error NoFunds();
    error NotTreasury();
    error TransferFailed();
    error IncorrectUSDCReceived();
    error UnderpaidVRFFee(uint256 required, uint256 supplied);
    error NativeRefundFailed();

    constructor(address coordinator) {
        // Mainnet can be deployed for verification, but starts with no deposits.
        // Only the fixed Treasury can explicitly activate it after review.
        if (block.chainid == 5042) {
            if (coordinator != ARC_MAINNET_COORDINATOR) revert InvalidCoordinator();
            depositsPaused = true;
        }
        if (coordinator.code.length == 0) revert InvalidCoordinator();
        vrfCoordinator = IPickCardVRF(coordinator);
    }

    /// @notice Emergency stop for new risk only. Cannot block claims, settlement
    ///         or eligible refunds, change results, or move escrow.
    function setDepositsPaused(bool paused) external {
        if (msg.sender != TREASURY) revert NotTreasury();
        depositsPaused = paused;
        emit DepositsPaused(paused);
    }

    /// @notice Creates a two-player pool and takes the creator's stake immediately.
    function createPool(uint256 stake) external nonReentrant returns (uint256 poolId) {
        if (depositsPaused) revert DepositsArePaused();
        if (stake == 0 || stake > type(uint256).max / 2 / BPS_DENOMINATOR) revert InvalidStake();

        poolId = nextPoolId++;
        Pool storage pool = _pools[poolId];
        pool.poolId = poolId;
        pool.creator = msg.sender;
        pool.stake = stake;
        pool.createdAt = block.timestamp;
        pool.status = PoolStatus.Open;

        _openPoolIndexPlusOne[poolId] = _openPoolIds.length + 1;
        _openPoolIds.push(poolId);
        _allPoolIds.push(poolId);
        _playerPoolIds[msg.sender].push(poolId);

        _pullUSDC(msg.sender, stake);
        emit PoolCreated(poolId, msg.sender, stake);
    }

    /// @notice Funds the second seat and requests two distinct card ranks.
    /// @dev msg.value pays the Arc-native VRF request fee; excess is returned.
    function joinPool(uint256 poolId) external payable nonReentrant returns (uint256 requestId) {
        if (depositsPaused) revert DepositsArePaused();
        Pool storage pool = _getPool(poolId);
        if (pool.status != PoolStatus.Open) revert PoolNotOpen();
        if (msg.sender == pool.creator) revert CannotJoinOwnPool();

        pool.opponent = msg.sender;
        pool.joinedAt = block.timestamp;
        pool.status = PoolStatus.Drawing;
        _playerPoolIds[msg.sender].push(poolId);
        _removeOpenPool(poolId);

        _pullUSDC(msg.sender, pool.stake);
        requestId = _requestCards(poolId, msg.sender, msg.value);
        emit PoolJoined(poolId, msg.sender, requestId);
    }

    /// @notice Retries only an expired-and-refunded VRF request for the same frozen players.
    function retryDraw(uint256 poolId) external payable nonReentrant returns (uint256 requestId) {
        if (depositsPaused) revert DepositsArePaused();
        Pool storage pool = _getPool(poolId);
        if (pool.status != PoolStatus.Drawing || pool.randomReady) revert DrawNotReady();
        if (pool.requestId != 0) revert DrawAlreadyRequested();
        if (msg.sender != pool.creator && msg.sender != pool.opponent) revert NotParticipant();
        // A player cannot front-run an eligible refund with another paid draw.
        if (block.timestamp >= pool.joinedAt + CANCEL_DELAY) revert RetryWindowClosed();
        requestId = _requestCards(poolId, msg.sender, msg.value);
    }

    /// @notice Settles a fulfilled VRF request. Anyone may call it.
    function settlePool(uint256 poolId) external nonReentrant {
        Pool storage pool = _getPool(poolId);
        if (pool.status != PoolStatus.Drawing || !pool.randomReady || pool.requestId == 0) {
            revert DrawNotReady();
        }

        // Map the accepted word locally using a pinned implementation. Never
        // re-read mutable external results, even during the callback.
        (uint8 creatorCard, uint8 opponentCard) = previewCards(acceptedRandomness[poolId]);
        address winner = creatorCard > opponentCard ? pool.creator : pool.opponent;
        uint256 pot = pool.stake * 2;
        uint256 treasuryFee = (pot * TREASURY_FEE_BPS) / BPS_DENOMINATOR;
        uint256 winnerPayout = pot - treasuryFee;

        pool.creatorCard = creatorCard;
        pool.opponentCard = opponentCard;
        pool.winner = winner;
        pool.winnerPayout = winnerPayout;
        pool.status = PoolStatus.Settled;

        pendingWithdrawals[winner] += winnerPayout;
        treasuryBalance += treasuryFee;

        emit PoolSettled(poolId, winner, creatorCard, opponentCard, winnerPayout, treasuryFee);
    }

    /// @notice The creator may cancel an unjoined pool after ten minutes.
    function cancelPool(uint256 poolId) external nonReentrant {
        Pool storage pool = _getPool(poolId);
        if (msg.sender != pool.creator) revert NotCreator();
        if (pool.status != PoolStatus.Open) revert PoolNotOpen();
        if (block.timestamp < pool.createdAt + CANCEL_DELAY) revert CancellationTooEarly();

        pool.status = PoolStatus.Cancelled;
        _removeOpenPool(poolId);
        pendingWithdrawals[pool.creator] += pool.stake;
        emit PoolCancelled(poolId, pool.creator, pool.stake);
    }

    /// @notice Returns both stakes after a VRF request was explicitly refunded and
    ///         ten minutes have elapsed since the second player joined.
    function cancelFailedDraw(uint256 poolId) external nonReentrant {
        Pool storage pool = _getPool(poolId);
        if (pool.status != PoolStatus.Drawing || pool.randomReady || pool.requestId != 0) {
            revert DrawNotReady();
        }
        if (msg.sender != pool.creator && msg.sender != pool.opponent) revert NotParticipant();
        if (block.timestamp < pool.joinedAt + CANCEL_DELAY) revert CancellationTooEarly();

        pool.status = PoolStatus.Cancelled;
        pendingWithdrawals[pool.creator] += pool.stake;
        pendingWithdrawals[pool.opponent] += pool.stake;
        emit FailedDrawCancelled(poolId, pool.stake);
    }

    function claim() external nonReentrant {
        uint256 amount = pendingWithdrawals[msg.sender];
        if (amount == 0) revert NoFunds();
        pendingWithdrawals[msg.sender] = 0;
        if (!USDC.transfer(msg.sender, amount)) revert TransferFailed();
        emit WithdrawalClaimed(msg.sender, amount);
    }

    function claimTreasury() external nonReentrant {
        if (msg.sender != TREASURY) revert NotTreasury();
        uint256 amount = treasuryBalance;
        if (amount == 0) revert NoFunds();
        treasuryBalance = 0;
        if (!USDC.transfer(TREASURY, amount)) revert TransferFailed();
        emit TreasuryClaimed(TREASURY, amount);
    }

    /// @notice Quotes a buffered base fee supplied by the frontend.
    function quoteDrawFeeAt(uint256 baseFee) external view returns (uint256) {
        return vrfCoordinator.quoteFeeAt(CALLBACK_GAS_LIMIT, baseFee);
    }

    function getPool(uint256 poolId) external view returns (Pool memory) {
        Pool storage pool = _getPool(poolId);
        return pool;
    }

    function getOpenPools() external view returns (uint256[] memory) {
        return _openPoolIds;
    }

    function getAllPools() external view returns (uint256[] memory) {
        return _allPoolIds;
    }

    function getMyPools(address player) external view returns (uint256[] memory) {
        return _playerPoolIds[player];
    }

    /// @notice Bounded newest-first enumeration. Open-pool order can change as
    ///         seats fill; callers should refresh page zero after mutations.
    function getPoolPage(uint8 kind, address player, uint256 offset, uint256 limit)
        external view returns (uint256[] memory ids, uint256 total)
    {
        if (kind > 2 || limit == 0 || limit > 50) revert InvalidPage();
        uint256[] storage source = kind == 0 ? _openPoolIds : kind == 1 ? _playerPoolIds[player] : _allPoolIds;
        total = source.length;
        if (offset >= total) return (new uint256[](0), total);
        uint256 count = total - offset;
        if (count > limit) count = limit;
        ids = new uint256[](count);
        for (uint256 i; i < count; ++i) ids[i] = source[total - offset - i - 1];
    }

    /// @notice Reproduce the pinned ChooseMany mapping for any delivered word.
    function previewCards(bytes32 randomness) public pure returns (uint8 creatorCard, uint8 opponentCard) {
        RandomnessMapping.Spec memory spec = RandomnessMapping.Spec({
            operation: RandomnessMapping.Operation.ChooseMany,
            lower: 0, upper: 0, count: 2, population: 13
        });
        uint256[] memory cards = RandomnessMapping.map(randomness, spec);
        return (uint8(cards[0] + 2), uint8(cards[1] + 2));
    }

    /// @notice Authenticated callback stores the word once. Local deterministic
    ///         mapping and settlement need no further coordinator calls.
    function rawFulfillRandomness(uint256 requestId, bytes32 randomness) external nonReentrant {
        if (msg.sender != address(vrfCoordinator)) revert UnexpectedCallback();
        uint256 poolId = requestPoolId[requestId];
        if (poolId == 0) revert UnexpectedCallback();
        Pool storage pool = _pools[poolId];
        if (pool.requestId != requestId || pool.randomReady || pool.status != PoolStatus.Drawing) {
            revert UnexpectedCallback();
        }
        acceptedRandomness[poolId] = randomness;
        pool.randomReady = true;
        emit RandomnessReady(poolId, requestId);
    }

    /// @notice Authenticated notification after the coordinator refunds an expired request.
    function onRefund(uint256 requestId) external nonReentrant {
        if (msg.sender != address(vrfCoordinator)) revert UnexpectedCallback();
        uint256 poolId = requestPoolId[requestId];
        if (poolId == 0) revert UnexpectedCallback();
        Pool storage pool = _pools[poolId];
        if (pool.requestId != requestId || pool.randomReady || pool.status != PoolStatus.Drawing) {
            revert UnexpectedCallback();
        }
        pool.requestId = 0;
        delete requestPoolId[requestId];
        emit RandomnessRefunded(poolId, requestId);
    }

    function _requestCards(uint256 poolId, address refundAddress, uint256 supplied)
        private
        returns (uint256 requestId)
    {
        uint256 fee = vrfCoordinator.quoteFee(CALLBACK_GAS_LIMIT);
        if (supplied < fee) revert UnderpaidVRFFee(fee, supplied);

        Pool storage pool = _pools[poolId];
        bytes32 clientSeed = keccak256(
            abi.encode(block.chainid, address(this), poolId, pool.creator, pool.opponent, pool.stake)
        );
        IPickCardVRF.Spec memory spec = IPickCardVRF.Spec({
            operation: IPickCardVRF.Operation.ChooseMany,
            lower: 0,
            upper: 0,
            count: 2,
            population: 13
        });

        requestId = vrfCoordinator.requestMappedRandomness{value: fee}(
            clientSeed,
            CALLBACK_GAS_LIMIT,
            refundAddress,
            spec
        );
        if (requestId == 0 || _usedRequestIds[requestId]) revert InvalidRequestId();
        _usedRequestIds[requestId] = true;
        pool.requestId = requestId;
        requestPoolId[requestId] = poolId;

        if (supplied > fee) {
            (bool refunded,) = payable(refundAddress).call{value: supplied - fee}("");
            if (!refunded) revert NativeRefundFailed();
        }
        emit RandomnessRequested(poolId, requestId);
    }

    function _pullUSDC(address from, uint256 amount) private {
        uint256 balanceBefore = USDC.balanceOf(address(this));
        if (!USDC.transferFrom(from, address(this), amount)) revert TransferFailed();
        if (USDC.balanceOf(address(this)) - balanceBefore != amount) revert IncorrectUSDCReceived();
    }

    function _getPool(uint256 poolId) private view returns (Pool storage pool) {
        pool = _pools[poolId];
        if (pool.poolId == 0) revert PoolDoesNotExist();
    }

    function _removeOpenPool(uint256 poolId) private {
        uint256 indexPlusOne = _openPoolIndexPlusOne[poolId];
        if (indexPlusOne == 0) return;
        uint256 index = indexPlusOne - 1;
        uint256 lastIndex = _openPoolIds.length - 1;
        if (index != lastIndex) {
            uint256 lastPoolId = _openPoolIds[lastIndex];
            _openPoolIds[index] = lastPoolId;
            _openPoolIndexPlusOne[lastPoolId] = index + 1;
        }
        _openPoolIds.pop();
        delete _openPoolIndexPlusOne[poolId];
    }
}
