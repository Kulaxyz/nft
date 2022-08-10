const { network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deployer } = await getNamedAccounts()

    const simpleNft = await deployments.deploy("SimpleNft", {
        from: deployer,
        arguments: [],
        log: true,
        waitConfirmations: 1,
    })

    if (!developmentChains.includes(network.name)) {
        await verify(simpleNft.address, [])
    }
}

module.exports.tags = ["all", "simple-nft"]