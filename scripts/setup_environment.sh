#!/bin/bash

# Allora macOS Environment Setup Script
# Prepares the system for Allora node deployment

echo "🚀 Allora macOS Environment Setup"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

print_status "Checking system requirements..."

# Check macOS version
macos_version=$(sw_vers -productVersion)
print_status "macOS version: $macos_version"

# Check if Homebrew is installed
if command -v brew >/dev/null 2>&1; then
    print_success "Homebrew is installed"
else
    print_warning "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Check and install Git
if command -v git >/dev/null 2>&1; then
    print_success "Git is installed: $(git --version)"
else
    print_status "Installing Git..."
    brew install git
fi

# Check and install Python3
if command -v python3 >/dev/null 2>&1; then
    print_success "Python3 is installed: $(python3 --version)"
else
    print_status "Installing Python3..."
    brew install python3
fi

# Check and install Ansible
if command -v ansible >/dev/null 2>&1; then
    print_success "Ansible is installed: $(ansible --version | head -n1)"
else
    print_status "Installing Ansible..."
    pip3 install ansible
fi

# Check and install jq
if command -v jq >/dev/null 2>&1; then
    print_success "jq is installed: $(jq --version)"
else
    print_status "Installing jq..."
    brew install jq
fi

# Check Docker Desktop
if command -v docker >/dev/null 2>&1; then
    print_success "Docker is installed: $(docker --version)"
    
    # Check if Docker daemon is running
    if docker ps >/dev/null 2>&1; then
        print_success "Docker daemon is running"
    else
        print_warning "Docker daemon is not running. Please start Docker Desktop."
    fi
else
    print_warning "Docker Desktop not found. Installing..."
    brew install --cask docker
    print_status "Please start Docker Desktop manually after installation"
fi

# Check Go installation
if command -v go >/dev/null 2>&1; then
    go_version=$(go version | awk '{print $3}' | sed 's/go//')
    print_success "Go is installed: $go_version"
    
    # Check if Go version is 1.23 or higher
    if [[ $(echo "$go_version 1.23" | tr " " "\n" | sort -V | head -n1) != "1.23" ]]; then
        print_warning "Go version $go_version is older than required 1.23+"
        print_status "Please update Go from https://golang.org/dl/"
    fi
else
    print_warning "Go not found. Please install Go 1.23+ from https://golang.org/dl/"
fi

# Check if allora-chain repository exists
if [[ -d "$HOME/allora-chain" ]]; then
    print_success "Allora chain repository found"
else
    print_status "Cloning Allora chain repository..."
    cd "$HOME"
    git clone https://github.com/allora-network/allora-chain.git
    cd allora-chain
    
    print_status "Building allorad binary..."
    make install
    
    if [[ -f "$HOME/go/bin/allorad" ]]; then
        print_success "allorad binary built successfully"
    else
        print_error "Failed to build allorad binary"
    fi
fi

# Create necessary directories
print_status "Creating necessary directories..."
mkdir -p "$HOME/.allorad/wallets"
mkdir -p "$HOME/Library/Logs"
mkdir -p "$HOME/Library/LaunchAgents"

# Set proper permissions
chmod 755 "$HOME/.allorad"
chmod 755 "$HOME/.allorad/wallets"

print_success "Directory structure created"

# Test Ansible connectivity
print_status "Testing Ansible connectivity..."
if ansible localhost -m ping >/dev/null 2>&1; then
    print_success "Ansible can connect to localhost"
else
    print_error "Ansible connectivity test failed"
fi

echo ""
print_success "Environment setup completed!"
echo ""
echo "📋 Next Steps:"
echo "=============="
echo "1. 💰 Create a wallet:"
echo "   ansible-playbook playbooks/create_wallet_macos.yml"
echo ""
echo "2. 🏗️  Deploy validator node:"
echo "   ansible-playbook playbooks/install_validator_node_macos.yml"
echo ""
echo "3. 📊 Manage services:"
echo "   ./scripts/manage_services.sh status all"
echo ""
echo "4. 🔍 Check worker health (after deploying worker):"
echo "   ./scripts/check_worker.sh"
echo ""

# Display system information
echo "💻 System Information:"
echo "====================="
echo "macOS Version: $macos_version"
echo "Architecture: $(uname -m)"
echo "Available RAM: $(sysctl hw.memsize | awk '{printf "%.2f GB", $2/1024/1024/1024}')"
echo "Available Disk: $(df -h / | awk 'NR==2{print $4}') free"
echo ""

print_success "Ready to deploy Allora nodes on macOS! 🎉"
