import { ethers } from "hardhat";

async function main() {
  const Renderer = await ethers.getContractFactory("Renderer");
  const NFTIME = await ethers.getContractFactory("NFTIME");

  const rendererContract = await Renderer.deploy();
  const nftimeContract = await NFTIME.deploy(rendererContract.address);

  await rendererContract.deployed();
  await nftimeContract.deployed();

  //await nftimeContract.mint(1893495600);

  console.log(`Renderer Contract deployed to https://goerli.etherscan.io/address/${rendererContract.address}`);
  console.log(`NFTIME Contract deployed to https://goerli.etherscan.io/address/${nftimeContract.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
