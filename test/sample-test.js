const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

const toWei = (num) => ethers.utils.parseEther(num.toString());
const fromWei = (num) => ethers.utils.formatEther(num);

describe("Staking",function(){
  let owner , addr1 ,addr2,staking,token;
  let secondsInDay = 24*60*60;
  let rptMultiplier = 10**1;
  let day = 28;


  beforeEach(async function(){
    const Token = await ethers.getContractFactory("Token");
    const Staking = await ethers.getContractFactory("Staking");
    [owner , addr1 ,addr2] = await ethers.getSigners();
    token = await Token.deploy();
    staking = await Staking.deploy(token.address , token.address);
  })


  describe("checking",function(){
    it("should check adding reward correctly , reward per token", async()=>{
 
      await token.approve(staking.address,toWei(300))
  
      await staking.addRewards(toWei(300), day);

      expect(await token.balanceOf(staking.address)).to.equal(toWei(300));
      
      let contractrpt = await staking.rewardPerTOken()
      let expectedrpt =  (toWei(300) * rptMultiplier / day / secondsInDay);
      
      expect(await contractrpt.toString()).to.equal(expectedrpt.toString());
    })

    it("should check deposit and withdraw",async()=>{
      await token.approve(staking.address,toWei(300))
  
      await staking.addRewards(toWei(300), day);

      let depositAmount = toWei(100)

      await token.approve(staking.address,depositAmount)
      await staking.deposit(depositAmount);
      let contractbalance = await token.balanceOf(staking.address);
      expect(await contractbalance.toString()).to.equal(toWei(400))

      let withdrawAmount = toWei(50)
      await staking.withdraw(withdrawAmount);
      expect(await contractbalance.toString()).to.equal(toWei(350))
    })


  })
})
