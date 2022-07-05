import ERC20ABI from '../contractsData/TOKEN.json'
import StakingABI from '../contractsData/Staking.json'
import ERC20ADDRESS from '../contractsData/TOKEN-address.json'
import StakingAddress from '../contractsData/Staking-address.json'

export const TokenABI = ERC20ABI.abi;
export const TokenAddress = ERC20ADDRESS.address;
export const STAKINGABI = StakingABI.abi;
export const STAKINGADDRESS = StakingAddress.address;