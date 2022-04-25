# Changer Contracts

## Mainnet

### Tokens

| Name      | Address                                                                                                                 | Description                                                       |
| --------- | ----------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| `CNG`     | [`0x5C1d9aA868a30795F92fAe903eDc9eFF269044bf`](https://etherscan.io/address/0x5C1d9aA868a30795F92fAe903eDc9eFF269044bf) | Main Changer Token. Any other sub tokens will be swapped to `CNG` |
| `ecoCNG`  | [`0x327612aCA8E619fe11bfA3dCb0a0c2C8B8688244`](https://etherscan.io/address/0x327612aCA8E619fe11bfA3dCb0a0c2C8B8688244) | Token for ecosystem development                                   |
| `teamCNG` | [`0x07305f5Dc6c75e93FeD3A10776EB3e92835Ef474`](https://etherscan.io/address/0x07305f5Dc6c75e93FeD3A10776EB3e92835Ef474) | Token for changer development team                                |
| `backCNG` | [`0x5aCbabF8E5eEC0f036b3728482A65614297ee3F9`](https://etherscan.io/address/0x5aCbabF8E5eEC0f036b3728482A65614297ee3F9) | Token for stake holders                                           |
| `pubCNG`  | [`0xa9b086064dfd25ef9B5C67afdc827E97E7Fed881`](https://etherscan.io/address/0xa9b086064dfd25ef9B5C67afdc827E97E7Fed881) | Token for public sale                                             |
| `strCNG`  | [`0x716B61aD04dC45F5508CFBaDff911B36E80A8d5E`](https://etherscan.io/address/0x716B61aD04dC45F5508CFBaDff911B36E80A8d5E) | Token pub strategic sale                                          |

### Swapper

| Name                               | Address                                                                                                                 | Description                              |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| `SwapperVault`                     | [`0x255Ecbc88B558aB68568dE2D43F8EFB9e33Fd2bd`](https://etherscan.io/address/0x255Ecbc88B558aB68568dE2D43F8EFB9e33Fd2bd) | Vault for NonLinearTimeLockSwapperV2     |
| `NonLinearTimeLockSwapperV2Proxy`  | [`0x0B59EF7D85F1acC791C937d2e9c40c020c156c6E`](https://etherscan.io/address/0x0B59EF7D85F1acC791C937d2e9c40c020c156c6E) | NonLinearTimeLockSwapperV2 proxy         |
| `NonLinearTimeLockSwapperV2@2.0.0` | [`0x557DE75A27025815dB74E16EA2B58eb7C2a1360f`](https://etherscan.io/address/0x557DE75A27025815dB74E16EA2B58eb7C2a1360f) | NonLinearTimeLockSwapperV2 logic (2.0.0) |
| `NonLinearTimeLockSwapperV2@2.0.1` | [`0x6971C1d22cCD76D3ca706523f3685E20faef9071`](https://etherscan.io/address/0x6971C1d22cCD76D3ca706523f3685E20faef9071) | NonLinearTimeLockSwapperV2 logic (2.0.1) |
| `NonLinearTimeLockSwapperV2@2.0.2` | [`0x83277787529dd950eC301fF700864971f1Dbb214`](https://etherscan.io/address/0x83277787529dd950eC301fF700864971f1Dbb214) | NonLinearTimeLockSwapperV2 logic (2.0.2) |
| `NonLinearTimeLockSwapperV2@2.0.3` | [`0xc816F766300A5DC86025eec1DA937061f0BC0815`](https://etherscan.io/address/0xc816F766300A5DC86025eec1DA937061f0BC0815) | NonLinearTimeLockSwapperV2 logic (2.0.3) |
| `NonLinearTimeLockSwapperV2@2.0.4` | [`0xb116ff33F48a6f45fb4A5d7413de433fDb67C399`](https://etherscan.io/address/0xb116ff33F48a6f45fb4A5d7413de433fDb67C399) | NonLinearTimeLockSwapperV2 logic (2.0.4) |

### Airdrop

| Name                    | Address                                                                                                                 | Description                   |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------- | ----------------------------- |
| `AirdropRegistryVault`  | [`0x7A595176043cA06FAF7523F73d39C5CA100169DF`](https://etherscan.io/address/0x7A595176043cA06FAF7523F73d39C5CA100169DF) | Vault for airdrop             |
| `AirdropRegistryProxy`  | [`0x8F9519cAa9876f3F0C4cB7fF380D1B4F988D64EC`](https://etherscan.io/address/0x8F9519cAa9876f3F0C4cB7fF380D1B4F988D64EC) | AirdropRegistry proxy         |
| `AirdropRegistry@1.0.0` | [`0x35Ce5B9E326A17db6807a7f2a85A3473E5cCdfac`](https://etherscan.io/address/0x35Ce5B9E326A17db6807a7f2a85A3473E5cCdfac) | AirdropRegistry logic (1.0.0) |

### MISC

| Name           | Address                                                                                                                 | Description                      |
| -------------- | ----------------------------------------------------------------------------------------------------------------------- | -------------------------------- |
| deployer (EOA) | [`0xcd9C21aa3e33b411c22C9120Ff4518dbF7daf8e8`](https://etherscan.io/address/0xcd9C21aa3e33b411c22C9120Ff4518dbF7daf8e8) | smart contract deployer          |
| `ProxyAdmin`   | [`0x25AAA82223405FFbCADd4b428B6c6A9BFf542F82`](https://etherscan.io/address/0x25AAA82223405FFbCADd4b428B6c6A9BFf542F82) | Transparent proxy contract admin |

## Smart Contract Dependencies

| Name                      | Version |
| ------------------------- | ------- |
| `@openzeppelin/contracts` | `4.1.0` |

## Instal

```bash
$ npm install
```

## Build

```bash
$ npx truffle compile
```
