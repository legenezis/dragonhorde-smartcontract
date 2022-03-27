const hre = require("hardhat");

async function main() {

  const [owner] = await hre.ethers.getSigners();
  const contractFactory = await hre.ethers.getContractFactory("DragonHorde");
  const contract = await contractFactory.deploy();
  await contract.deployed();

  console.log("DragonHorde deployed to: ", contract.address);
  console.log("DragonHorde owner address: ", owner.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
