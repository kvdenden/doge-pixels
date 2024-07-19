# Deployment steps

## Sepolia

### deploy dog

- forge script script/DOG20.s.sol:Deploy --broadcast --verify --slow --rpc-url sepolia
- set DOG20_ADDRESS env variable

### deploy px

- forge script script/PX.s.sol:Deploy --broadcast --verify --slow --rpc-url sepolia
- set PX_ADDRESS env variable

### deploy bridged dog

- forge script script/DOG20.s.sol:DeployL2 --broadcast --verify --slow --rpc-url base_sepolia
- set DOG20_L2_ADDRESS env variable

### deploy px bridge

- forge script script/PXBridge.s.sol:DeployL1 --broadcast --verify --slow --rpc-url sepolia
- set PXBRIDGE_L1_ADDRESS env variable

- forge script script/PXBridge.s.sol:DeployL2 --broadcast --verify --slow --rpc-url base_sepolia
- set PXBRIDGE_L2_ADDRESS env variable

### deploy bridged px

- forge script script/BridgedPX.s.sol:Deploy --broadcast --verify --slow --rpc-url base_sepolia
- set PX_L2_ADDRESS env variable

### configure px bridge

- forge script script/PXBridge.s.sol:ConfigL1 --broadcast --verify --slow --rpc-url sepolia
- forge script script/PXBridge.s.sol:ConfigL2 --broadcast --verify --slow --rpc-url base_sepolia

### upgrade px

- forge script script/PX.s.sol:Upgrade --broadcast --verify --slow --rpc-url sepolia

## Mainnet

### set existing contract addresses

- set DOG20_ADDRESS env variable
- set DOG20_L2_ADDRESS env variable
- set PX_ADDRESS env variable

### deploy px bridge

- forge script script/PXBridge.s.sol:DeployL1 --broadcast --verify --slow --rpc-url mainnet
- set PXBRIDGE_L1_ADDRESS env variable

- forge script script/PXBridge.s.sol:DeployL2 --broadcast --verify --slow --rpc-url base
- set PXBRIDGE_L2_ADDRESS env variable

### deploy bridged px

- forge script script/BridgedPX.s.sol:Deploy --broadcast --verify --slow --rpc-url base
- set PX_L2_ADDRESS env variable

### configure px bridge

- forge script script/PXBridge.s.sol:ConfigL1 --broadcast --verify --slow --rpc-url mainnet
- forge script script/PXBridge.s.sol:ConfigL2 --broadcast --verify --slow --rpc-url base

### upgrade px

- forge script script/PX.s.sol:Upgrade --broadcast --verify --slow --rpc-url mainnet

### bridge pixels

- forge script script/PX.s.sol:Bridge --broadcast --verify --slow --rpc-url mainnet

### hand over bridge ownership
