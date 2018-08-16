#!/usr/bin/env bash

# Read the IPFS PeerID from an IPFS configuration file and export the IPFS_SWARM
# environment variable based on that PeerID

PEER_ID=$(awk -F '\"' ' /'PeerID'/ {print $4}' $1)
PREFIX='/ip4/127.0.0.1/tcp/9012/ws/ipfs/'

export IPFS_SWARM="$PREFIX$PEER_ID"
