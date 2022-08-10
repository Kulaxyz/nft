const { network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")
const { storeImages, storeTokenUriMetadata } = require("../utils/uploadFile")

const imagesPath = "./images"

const metadataTemplate = {
    name: "",
    description: "",
    image: "",
    attributes: [],
}

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deployer } = await getNamedAccounts()

    const { responses, files } = await storeImages(imagesPath)
    const tokenUris = await getUris(responses, files)
    console.log(`Uploaded ${tokenUris.length} images!!`)
    console.log(tokenUris)

    if (!developmentChains.includes(network.name)) {
        await verify(simpleNft.address, [])
    }
}

async function getUris(imageUploadResponses, files) {
    let tokenUris = []
    for (imageUploadResponseIndex in imageUploadResponses) {
        let tokenUriMetadata = { ...metadataTemplate }
        tokenUriMetadata.name = files[imageUploadResponseIndex].replace(".jpeg", "")
        tokenUriMetadata.description = `An adorable ${tokenUriMetadata.name} pokemon!`
        tokenUriMetadata.image = `ipfs://${imageUploadResponses[imageUploadResponseIndex].IpfsHash}`
        console.log(`Uploading ${tokenUriMetadata.name}...`)
        const metadataUploadResponse = await storeTokenUriMetadata(tokenUriMetadata)
        tokenUris.push(`ipfs://${metadataUploadResponse.IpfsHash}`)
    }
    return tokenUris

}

module.exports.tags = ["all", "ipfs-nft"]