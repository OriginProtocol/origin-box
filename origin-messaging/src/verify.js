'use strict'

import Web3 from 'web3'
import * as config from './config'

const web3 = new Web3(config.RPC_SERVER)

function verifyConversationSignature(keysMap) {
  return (signature, key, message, buffer) => {
    const verifyAddress = web3.eth.accounts.recover(
      buffer.toString('utf8'),
      signature
    )
    // Hopefully the last 42 is the eth address
    const ethAddress = message.id.substr(-42)
    // Only one of the two conversers can set this parameter
    if (key == message.payload.key || key == ethAddress) {
      const entry = keysMap.get(key)
      return entry.address == verifyAddress
    }
    return false
  }
}

function verifyConversers(conversee, keysMap){
  return (o, contentObject) => {
    const checkString = joinConversationKey(conversee, o.parentSub) +
      contentObject.ts.toString()

    const verifyAddress = web3.eth.accounts.recover(checkString, contentObject.sig)

    const parentKey = keysMap.get(o.parentSub)
    const converseeKey = keysMap.get(conversee)

    if ((parentKey && verifyAddress == parentKey.address) ||
        (converseeKey && verifyAddress == keysMap.get(conversee).address)) {
      console.log(`
        Verified conv init for ${conversee}
        Signature: ${contentObj.sign}
        Signed with: ${verifyAddress}
      `)
      return true
    }
    return false
  }
}

function verifyMessageSignature(keysMap) {
  return (signature, key, message, buffer) => {
    console.log(`
      Verify message: ${message}
      Key: ${key}
      Signature: ${signature}
    `)

    const verifyAddress = web3.eth.accounts.recover(
      buffer.toString('utf8'),
      signature
    )
    const entry = keysMap.get(key)

    //only two addresses should have write access to here
    return entry.address == verifyAddress
  }
}

function verifyRegistrySignature(signature, key, message) {
  const value = message.payload.value
  const setKey = message.payload.key
  const verifyAddress = web3.eth.accounts.recover(value.msg, signature)

  if (verifyAddress == setKey && value.msg.includes(value.address)) {
    const extractedAddress = '0x' + web3.utils.sha3(value.pub_key).substr(-40)

    if (extractedAddress == value.address.toLowerCase()) {

      const verifyPhAddress = web3.eth.accounts.recover(value.ph, value.phs)
      if (verifyPhAddress == value.address) {
        console.log(`
          Key verified: ${value.msg}
          Signature: ${signature}
          Signed with, ${verifyAddress}
        `)
        return true
      }
    }
  }

  console.log('Key verify failed...')

  return false
}

module.exports = {
  verifyConversationSignature,
  verifyConversers,
  verifyMessageSignature,
  verifyRegistrySignature
}
