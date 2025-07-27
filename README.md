# Allora Node Deployment for macOS

A comprehensive, macOS-native deployment toolkit for Allora blockchain validator and worker nodes using `launchd` service management.

## 🚀 Features

- **macOS Native**: Designed specifically for macOS using `launchd` instead of `systemd`
- **Ansible Automation**: Fully automated deployment using Ansible playbooks
- **Service Management**: Easy start/stop/status management with native macOS tools
- **Multiple Node Types**: Support for both validator and worker nodes
- **AI/ML Models**: Support for Chronos, LSTM, and Prophet prediction models
- **Wallet Management**: Integrated wallet creation and management
- **Docker Integration**: Worker nodes with containerized AI models

## 📋 Prerequisites

### System Requirements
- **macOS**: 12.0 (Monterey) or later
- **Memory**: 8 GB RAM minimum, 16 GB recommended
- **Storage**: 100 GB free space minimum
- **CPU**: 4 cores minimum, 6+ cores recommended

### Required Software
- **Docker Desktop**: For worker nodes
- **Python 3**: For Ansible (usually pre-installed)
- **Homebrew**: Package manager for macOS
- **Git**: Version control
- **Go 1.23+**: For building Allora binary

### Installation Commands
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required packages
brew install git python3

# Install Ansible
pip3 install ansible

# Install Docker Desktop
brew install --cask docker

# Verify Go version (should be 1.23+)
go version
```

## 🛠 Quick Start

### 1. Clone and Setup
```bash
git clone <repository-url> allora-macos-deployment
cd allora-macos-deployment
chmod +x scripts/*.sh
```

### 2. Create a Wallet
```bash
ansible-playbook playbooks/create_wallet_macos.yml
```

### 3. Deploy Validator Node
```bash
ansible-playbook playbooks/install_validator_node_macos.yml
```

### 4. Deploy Worker Node (Optional)
```bash
ansible-playbook playbooks/install_worker_node_macos.yml
```

## 📁 Repository Structure

```
allora-macos-deployment/
├── README.md                          # This file
├── ansible.cfg                        # Ansible configuration
├── inventory                          # Ansible inventory (localhost)
├── playbooks/                         # Ansible playbooks
│   ├── create_wallet_macos.yml        # Wallet creation
│   ├── install_validator_node_macos.yml # Validator deployment
│   ├── install_worker_node_macos.yml  # Worker deployment
│   └── manage_services_macos.yml      # Service management
├── templates/                         # Configuration templates
│   ├── com.allora.validator.plist.j2  # Validator service
│   ├── com.allora.worker.plist.j2     # Worker service
│   ├── config.json.j2                 # Worker configuration
│   ├── docker-compose.yaml.j2         # Docker compose
│   ├── Dockerfile.j2                  # Docker container
│   ├── requirements.txt.j2            # Python requirements
│   └── app_*.py.j2                    # AI model scripts
└── scripts/                           # Utility scripts
    ├── manage_services.sh              # Service management
    ├── check_worker.sh                 # Worker health check
    └── setup_environment.sh            # Environment setup
```

## 🔧 Service Management

### Using the Management Script
```bash
# Check status of all services
./scripts/manage_services.sh status all

# Start validator node
./scripts/manage_services.sh start validator

# Stop worker node
./scripts/manage_services.sh stop worker

# View logs
./scripts/manage_services.sh logs validator

# Restart services
./scripts/manage_services.sh restart all
```

### Manual launchd Commands
```bash
# Load and start validator
launchctl load ~/Library/LaunchAgents/com.allora.validator.plist

# Stop and unload worker
launchctl unload ~/Library/LaunchAgents/com.allora.worker.plist

# Check service status
launchctl list | grep allora

# View logs
tail -f ~/Library/Logs/allora-validator.log
tail -f ~/Library/Logs/allora-worker.log
```

## 🤖 Worker Node AI Models

### Supported Models
1. **Chronos**: Amazon's time series forecasting model
2. **LSTM**: Long Short-Term Memory neural networks
3. **Prophet**: Facebook's time series forecasting tool

### Supported Cryptocurrencies
- **ETH** (Ethereum) - Topics 1, 2, 7
- **BTC** (Bitcoin) - Topics 3, 4
- **SOL** (Solana) - Topics 5, 6
- **BNB** (Binance Coin) - Topic 8
- **ARB** (Arbitrum) - Topic 9

### Testing Worker Node
```bash
# Check worker functionality
./scripts/check_worker.sh

# Manual API test
curl -X POST 'http://localhost:6000/api/v1/functions/execute' \
-H 'Content-Type: application/json' \
-d '{
  "function_id": "bafybeigpiwl3o73zvvl6dxdqu7zqcub5mhg65jiky2xqb4rdhfmikswzqm",
  "method": "allora-inference-function.wasm",
  "parameters": null,
  "topic": "1",
  "config": {
    "env_vars": [
      {"name": "BLS_REQUEST_PATH", "value": "/api"},
      {"name": "ALLORA_ARG_PARAMS", "value": "ETH"}
    ],
    "number_of_nodes": -1,
    "timeout": 2
  }
}'
```

## 💰 Wallet Operations

### Create New Wallet
```bash
ansible-playbook playbooks/create_wallet_macos.yml -e wallet_name="my_wallet"
```

### Check Wallet Balance
```bash
# Replace with your wallet address
/Users/$USER/go/bin/allorad query bank balances <wallet_address> --node https://allora-rpc.testnet.allora.network/
```

### List All Wallets
```bash
/Users/$USER/go/bin/allorad keys list --keyring-backend test
```

## 🔍 Troubleshooting

### Common Issues

#### Docker Not Starting
```bash
# Restart Docker Desktop
killall "Docker Desktop"
open -a Docker
# Wait 60 seconds for full startup
```

#### Service Won't Start
```bash
# Check service status
launchctl list | grep allora

# View error logs
tail -n 50 ~/Library/Logs/allora-validator-error.log
tail -n 50 ~/Library/Logs/allora-worker-error.log

# Reload service
launchctl unload ~/Library/LaunchAgents/com.allora.validator.plist
launchctl load ~/Library/LaunchAgents/com.allora.validator.plist
```

#### Node Not Syncing
```bash
# Check node status
/Users/$USER/go/bin/allorad status --home ~/.allorad

# Check network connectivity
curl -s https://allora-rpc.testnet.allora.network/status | jq .result.sync_info
```

#### Build Errors
```bash
# Update Go if needed
# Check current version
go version

# If older than 1.23, update:
# Download from https://golang.org/dl/
# Or use Homebrew: brew install go
```

## 📊 Monitoring

### Log Files
- **Validator**: `~/Library/Logs/allora-validator.log`
- **Worker**: `~/Library/Logs/allora-worker.log`
- **Errors**: `~/Library/Logs/allora-*-error.log`

### Key Metrics to Monitor
- Node sync status
- Peer connections
- Memory usage
- Disk space
- Worker API responses

## 🔗 Useful Links

- **Allora Network**: [Official Website](https://allora.network)
- **Allora GitHub**: [allora-network](https://github.com/allora-network)
- **Testnet RPC**: https://allora-rpc.testnet.allora.network/
- **Documentation**: [Allora Docs](https://docs.allora.network)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on macOS
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This deployment toolkit is for testnet use only. Always backup your wallets and private keys. Use at your own risk in production environments.
