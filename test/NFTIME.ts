import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";

describe("NFTIME", function () {
  async function getContractsFixture() {
    const [owner] = await ethers.getSigners();

    const Renderer = await ethers.getContractFactory("Renderer");
    const NFTime = await ethers.getContractFactory("NFTIME");

    const rendererContract = await Renderer.deploy();
    const nftimeContract = await NFTime.deploy(rendererContract.address);

    await rendererContract.deployed();
    await nftimeContract.deployed();

    return { nftimeContract, owner };
  }

  it("Check mint function", async function () {
    const dateNow = Date.now();
    dateNow.toLocaleString
    const { nftimeContract } = await loadFixture(getContractsFixture);

    await nftimeContract.mint(1893495600);

    const tokenIdToTime = await nftimeContract.tokenIdToTime(1)
    const tokenIdToTimeStruct = await nftimeContract.tokenIdToTimeStruct(1)
    console.log(tokenIdToTime);
    console.log(tokenIdToTimeStruct);
  });
});