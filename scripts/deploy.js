
let tokenaddress ="0x876e1214f9499A6809F2aD8786567878D42FD2f0"

async function main() {

  // const ERC20 = await ethers.getContractFactory("TOKEN");
  // const token = await ERC20.deploy();

  const STAKING = await ethers.getContractFactory("Staking");
  const staking  = await STAKING.deploy(tokenaddress,tokenaddress)


  console.log("Greeter deployed to:", staking.address);

  saveFrontendFiles(staking , "Staking")

  function saveFrontendFiles(contract, name) {
    const fs = require("fs");
    const contractsDir = __dirname + "/../src/contractsData";
  
    if (!fs.existsSync(contractsDir)) {
      fs.mkdirSync(contractsDir);
    }
  
    fs.writeFileSync(
      contractsDir + `/${name}-address.json`,
      JSON.stringify({ address: contract.address }, undefined, 2)
    );
  
    const contractArtifact = artifacts.readArtifactSync(name);
  
    fs.writeFileSync(
      contractsDir + `/${name}.json`,
      JSON.stringify(contractArtifact, null, 2)
    );
  }


}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
