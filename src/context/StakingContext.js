import React, { useEffect, useState } from 'react'
import { ethers } from 'ethers'
import { TokenABI, TokenAddress, STAKINGABI, STAKINGADDRESS } from './Instance'

export const StakingContext = React.createContext()

const { ethereum } = window

const loadingcontract = () => {
  const provider = new ethers.providers.Web3Provider(ethereum)
  const signer = provider.getSigner()
  const TokenContract = new ethers.Contract(TokenAddress, TokenABI, signer)
  const StakingContract = new ethers.Contract(
    STAKINGADDRESS,
    STAKINGABI,
    signer,
  )

  return TokenContract, StakingContract
}

export const StakingProvider = ({ children }) => {
  const [currentAccount, setCurrentAccount] = useState(null)

  const checkIfWalletIsConnect = async () => {
    try {
      if (!ethereum) return alert('Please install MetaMask.')

      const accounts = await ethereum.request({ method: 'eth_accounts' })

      if (accounts.length) {
        setCurrentAccount(accounts[0])

        getAllTransactions()
      } else {
        console.log('No accounts found')
      }
    } catch (error) {
      console.log(error)
    }
  }

  const connectWallet = async () => {
    try {
      if (!ethereum) return alert('Please install MetaMask.')

      const accounts = await ethereum.request({ method: 'eth_requestAccounts' })

      setCurrentAccount(accounts[0])
      window.location.reload()
    } catch (error) {
      console.log(error)

      throw new Error('No ethereum object')
    }
  }

  useEffect(() => {
    checkIfWalletIsConnect();
  }, [])

  return(
  <StakingContext.Provider value={{
    currentAccount,
    loadingcontract,
    connectWallet
  }}
  )
}
