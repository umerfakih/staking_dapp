// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Staking is ReentrancyGuard, Ownable  {
    using SafeMath for uint256;

    struct UserInfo{
        uint256 deposited;
        uint256 rewardsAlreadyConsidered;
    }

    mapping(address=>UserInfo) users;
    
    uint256 public totalStaked;

    IERC20 public StakingToken;

    IERC20 public RewardToken;

    uint256 public rewardPerTOken;

    uint256 public lastRewardTimeStamp;

    uint256 public rewardPeriodEndTimestamp;

    uint256 public accumulatedRewardPerShare;


    event AddRewards(uint256 amount , uint256 lengthInDays);
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event ClaimReward(address indexed user, uint256 amount);

    constructor(address _Stakingtoken, address _Rewardtoken)
    {
        StakingToken = IERC20(_Stakingtoken);
        RewardToken = IERC20(_Rewardtoken);
    }


    function addRewards(uint256 _rewardAmount, uint256 _lengthindays)external onlyOwner nonReentrant{
        require(StakingToken.balanceOf(msg.sender) >= _rewardAmount);
        require(block.timestamp > rewardPeriodEndTimestamp,"cant stake before period finish");
        updateRewards();
        rewardPeriodEndTimestamp = block.timestamp.add(_lengthindays.mul(24*60*60));
        rewardPerTOken = _rewardAmount.mul(1e1).div(_lengthindays).div(24*60*60);
        (StakingToken.transferFrom(msg.sender,address(this),_rewardAmount) , "transfer failed aprrove first  or you dont have enough token");
        emit AddRewards(_rewardAmount , _lengthindays);
    }
    
    function updateRewards() public {
      if (block.timestamp <= lastRewardTimeStamp) {
            return;
        }
        if ((totalStaked == 0) || lastRewardTimeStamp > rewardPeriodEndTimestamp) {
            lastRewardTimeStamp = block.timestamp;
            return;
        }
       
        uint256 endingTime;
        if (block.timestamp > rewardPeriodEndTimestamp) {
            endingTime = rewardPeriodEndTimestamp;
        } else {
            endingTime = block.timestamp;
        }

        uint256 secondsSinceLastRewardUpdate = endingTime.sub(lastRewardTimeStamp);

        uint256 totalNewReward = secondsSinceLastRewardUpdate.mul(rewardPerTOken); // For everybody in the pool

        accumulatedRewardPerShare = accumulatedRewardPerShare.add(totalNewReward.mul(1e6).div(totalStaked));

        lastRewardTimeStamp = block.timestamp;
        
        if (block.timestamp > rewardPeriodEndTimestamp) {
            rewardPerTOken = 0;
        }
    }


    function deposit(uint256 _amount) external nonReentrant{
        UserInfo storage user = users[msg.sender];
        require(StakingToken.balanceOf(msg.sender) >= _amount);
        updateRewards();

        if(user.deposited > 0){
            uint256 pendingRewards = user.deposited.mul(accumulatedRewardPerShare).div(1e6).div(1e1).sub(user.rewardsAlreadyConsidered);
            require(RewardToken.transfer(msg.sender,pendingRewards),"transfer failed");
            emit ClaimReward(msg.sender,pendingRewards);
        }

        user.deposited= user.deposited.add(_amount);
        totalStaked = totalStaked.add(_amount);
        user.rewardsAlreadyConsidered=user.deposited.mul(accumulatedRewardPerShare).div(1e6).div(1e1);
        (StakingToken.transferFrom(msg.sender,address(this),_amount),"You dont have enough token");
        emit Deposit(msg.sender,_amount);
    }

    function withdraw(uint256 _amount) external nonReentrant {
        UserInfo storage user = users[msg.sender];
        require(user.deposited >= _amount,"you are withdrawing more than you deposited");
        updateRewards();
        uint256 pending = user.deposited.mul(accumulatedRewardPerShare).div(1e6).div(1e1).sub(user.rewardsAlreadyConsidered);
        require(RewardToken.transfer(msg.sender,pending));
        emit ClaimReward(msg.sender,pending);
        user.deposited = user.deposited.sub(_amount);
        totalStaked = totalStaked.sub(_amount);
        user.rewardsAlreadyConsidered = user.deposited.mul(accumulatedRewardPerShare).div(1e6).div(1e1);
        StakingToken.transfer(msg.sender,_amount);
        emit Withdraw(msg.sender,_amount);
    }

    function Claim() external{
        UserInfo storage user = users[msg.sender];
        if(user.deposited == 0 ){
            return;
        }
        updateRewards();
        uint256 pending = user.deposited.mul(accumulatedRewardPerShare).div(1e6).div(1e1).sub(user.rewardsAlreadyConsidered);
        require(RewardToken.transfer(msg.sender,pending));
        emit ClaimReward(msg.sender,pending);
        user.rewardsAlreadyConsidered = user.deposited.mul(accumulatedRewardPerShare).div(1e6).div(1e1);
    }

    function PendingRewards(address _user) public view returns(uint256){
        UserInfo storage user = users[msg.sender];
        uint256 accumulated = accumulatedRewardPerShare;
        if(block.timestamp > lastRewardTimeStamp && lastRewardTimeStamp <= rewardPeriodEndTimestamp && totalStaked != 0){
            uint256 endtime;
            if(block.timestamp > rewardPeriodEndTimestamp){
                endtime = rewardPeriodEndTimestamp;
            }
            else{
                endtime = block.timestamp;
            }

            uint256 secondsSinceLastRewardUpdate = endtime.sub(lastRewardTimeStamp);
            uint256 totalNewReward = secondsSinceLastRewardUpdate.mul(rewardPerTOken);
            accumulated = accumulated.add(totalNewReward.mul(1e6).div(totalStaked));
        }
        return user.deposited.mul(accumulated).div(1e6).div(1e1).sub(user.rewardsAlreadyConsidered);
    }

    function getFrontendView() external view returns(uint256 _rewardpersecond, uint256 _secondsleft,uint256 _deposited,uint256 _pending){
        if(block.timestamp <= rewardPeriodEndTimestamp){
            _secondsleft = rewardPeriodEndTimestamp.sub(block.timestamp);
            _rewardpersecond = rewardPerTOken.div(1e1);
        }
        _deposited = users[msg.sender].deposited;
        _pending = PendingRewards(msg.sender);
    }
}