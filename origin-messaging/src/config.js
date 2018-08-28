require('dotenv').config()

module.exports = Object.freeze({
  GLOBAL_KEYS: `${process.env.MESSAGING_NAMESPACE}:global`,
  CONV_INIT_PREFIX: `${process.env.MESSAGING_NAMESPACE}:convo-init-`,
  CONV: `${process.env.MESSAGING_NAMESPACE}:conv`,
  IPFS_ADDRESS: process.env.IPFS_ADDRESS || 'localhost',
  IPFS_PORT: process.env.IPFS_PORT || '5001',
  RPC_SERVER: process.env.RPC_SERVER
})
