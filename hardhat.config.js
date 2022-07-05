require("@nomiclabs/hardhat-waffle");
require("dotenv").config()
const {API_URL,Private_key} = process.env
module.exports = {
  solidity: "0.8.4",
  networks:{
    Ropsten:{
      url : API_URL,
      accounts:[Private_key]
    }
  }
};
