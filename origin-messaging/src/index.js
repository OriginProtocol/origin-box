'use strict'

import OrbitDB from 'orbit-db'
import Keystore from 'orbit-db-keystore'
import url from 'url'

const Log = require('ipfs-log')
const IpfsApi = require('ipfs-api')

import * as config from './config'
import InsertOnlyKeystore from './insert-only-keystore'
import exchangeHeads from './exchange-heads'
import {
  verifyConversationSignature,
  verifyConversers,
  verifyMessageSignature,
  verifyRegistrySignature
} from './verify'

const ipfs = IpfsApi(config.IPFS_ADDRESS, config.IPFS_PORT)

process.env.LOG = 'DEBUG'

//the OrbitDB should be the message one
const messagingRoomsMap = {}

async function startRoom(roomDb, roomId, storeType, writers, shareFunc) {
  let key = roomId
  if (writers.length != 1 || writers[0] != '*') {
    key = roomId + '-' +  writers.join('-')
  }

  console.log(`Checking key: ${key}`)

  if(!messagingRoomsMap[key]) {
    messagingRoomsMap[key] = 'pending'
    const room = await roomDb[storeType](roomId, { write:writers })

    console.log(`Room started: ${room.id}`)

    if (shareFunc) {
      shareFunc(room)
    }
    messagingRoomsMap[key] = room
    rebroadcastOnReplicate(roomDb, room)
    //for persistence replace drop with below
    //room.load()
    startSnapshotDB(room)
  }
}

function joinConversationKey(converser1, converser2) {
  return [converser1, converser2].sort().join('-')
}

function onConverse(roomDb, conversee, payload){
    const converser = payload.key
    console.log(`Started conversation between: ${converser} and ${conversee}`)
    const writers = [converser, conversee].sort()
    startRoom(roomDb, config.CONV, 'eventlog', writers)
}

function handleGlobalRegistryWrite(convInitDb, payload) {
  if (payload.op == 'PUT') {
    const ethAddress = payload.key
    console.log(`Started conversation for: ${ethAddress}`)
    startRoom(convInitDb, config.CONV_INIT_PREFIX + ethAddress, 'kvstore', ['*'])
  }
}

function rebroadcastOnReplicate(DB, db){
  db.events.on('replicated', (dbname) => {
    // rebroadcast
    DB._pubsub.publish(db.id,  db._oplog.heads)
    snapshotDB(db)
  })
}

async function pinIPFS(entry, signature, key) {
  if (ipfs.pin && ipfs.pin.add) {
    const hash = await saveToIpfs(ipfs, entry, signature, key)
    if (hash) {
      console.log(`Pinning hash ${hash}`)

      try {
        return await ipfs.pin.add(hash)
      } catch (err) {
        console.error(`Cannot pin verified entry hash: ${hash}`)
      }
    }
  }
}

async function saveToIpfs(ipfs, entry, signature, key) {
  if (!entry) {
    console.warn('Warning: Given input entry was null.')
    return null
  }

  const logEntry = Object.assign({}, entry)
  logEntry.hash = null

  if (signature) {
    logEntry.sig = signature
  }

  if (key) {
    logEntry.key = key
  }

  return ipfs.object.put(Buffer.from(JSON.stringify(logEntry)))
    .then((dagObj) => dagObj.toJSON().multihash)
    .then(hash => {
      // We need to make sure that the head message's hash actually
      // matches the hash given by IPFS in order to verify that the
      // message contents are authentic
      if (entry.hash) {
        if(entry.hash != hash) {
          console.warn(`Hash mismatch: ${hash} from ${entry}`)
        }
      }
      else {
        console.warn(`Hash: ${hash} from ${logEntry}`)
      }
      return hash
    })
}

async function snapshotDB(db)
{
  const unfinished = db._replicator.getQueue()
  const snapshotData = db._oplog.toSnapshot()

  await db._cache.set('queue', unfinished)
  await db._cache.set('raw_snapshot', snapshotData)
  console.log('Saved snapshot:', snapshotData.id, ' queue:', unfinished.length)
}

async function loadSnapshotDB(db)
{
  const queue = await db._cache.get('queue')
  db.sync(queue || [])
  const snapshotData = await db._cache.get('raw_snapshot')
  if (snapshotData) {
    for (const entry of snapshotData.values){
      await saveToIpfs(db._ipfs, entry)
    }
    const log = new Log(
      db._ipfs,
      snapshotData.id,
      snapshotData.values,
      snapshotData.heads,
      null,
      db._key,
      db.access.write
    )
    await db._oplog.join(log)
    await db._updateIndex()
    db.events.emit('replicated', db.address.toString())
  }
  db.events.emit('ready', db.address.toString(), db._oplog.heads)
}

async function startSnapshotDB(db)
{
  await loadSnapshotDB(db)
}


async function _onPeerConnected(address, peer)
{
  const getStore = address => this.stores[address]
  const getDirectConnection = peer => this._directConnections[peer]
  const onChannelCreated = channel => this._directConnections[channel._receiverID] = channel
  const onMessage = (address, heads) => this._onMessage(address, heads)

  const channel = await exchangeHeads(
    this._ipfs,
    address,
    peer,
    getStore,
    getDirectConnection,
    onMessage,
    onChannelCreated
  )

  if (getStore(address))
    getStore(address).events.emit('peer', peer)
}

const startOrbitDbServer = async () => {
  // Remap the peer connected to ours which will wait before exchanging heads
  // with the same peer
  const orbitGlobal = new OrbitDB(
    ipfs,
    'odb/Main',
    { keystore: new InsertOnlyKeystore() }
  )

  orbitGlobal._onPeerConnected = _onPeerConnected

  orbitGlobal.keystore.registerSignVerify(
    config.GLOBAL_KEYS,
    undefined,
    verifyRegistrySignature,
    message => {
      handleGlobalRegistryWrite(orbitGlobal, message.payload)
    }
  )

  const globalRegistry = await orbitGlobal.kvstore(
    config.GLOBAL_KEYS, { write: ['*'] }
  )
  rebroadcastOnReplicate(orbitGlobal, globalRegistry)

  orbitGlobal.keystore.registerSignVerify(
    config.CONV_INIT_PREFIX,
    undefined,
    verifyConversationSignature(globalRegistry),
    message => {
      // Hopefully the last 42 is the eth address
      const ethAddress = message.id.substr(-42)
      onConverse(orbitGlobal, ethAddress, message.payload)
    }
  )

  orbitGlobal.keystore.registerSignVerify(
    config.CONV, undefined, verifyMessageSignature(globalRegistry)
  )

  console.log(`Orbit registry started...: ${globalRegistry.id}`)

  globalRegistry.events.on('ready', (address) => {
    console.log(`Ready... ${globalRegistry.all()}`)
  })

  // testing it's best to drop this for now
  // global_registry.load()
  startSnapshotDB(globalRegistry)
}

const main = async () => {
  const ipfsId = ipfs.id()

  await ipfsId.then((id) => {
    console.log(`Connected to IPFS server: ${id}`)
    startOrbitDbServer()
  }).catch((error) => {
    console.log(`Could not connect to IPFS at ${config.IPFS_ADDRESS}:${config.IPFS_PORT}...`)
    setTimeout(main, 5000)
  })
}

main()
