#!/bin/bash

# setup_check.sh - Comprehensive setup verification and installation script
# This script checks all prerequisites for the Ridges Agent Workbench and attempts to fix issues

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Status tracking
ISSUES_FOUND=0
FIXES_APPLIED=0

# Helper functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_fix() {
    echo -e "${GREEN}🔧 $1${NC}"
    FIXES_APPLIED=$((FIXES_APPLIED + 1))
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Python version
check_python() {
    print_header "Checking Python Installation"
    
    if command_exists python3; then
        PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
        PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
        PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)
        
        if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 11 ]; then
            print_success "Python $PYTHON_VERSION found (requirement: 3.11+)"
        else
            print_error "Python $PYTHON_VERSION found, but 3.11+ is required"
            print_info "Please install Python 3.11 or later:"
            print_info "  macOS: brew install python@3.11"
            print_info "  Ubuntu: sudo apt install python3.11"
            print_info "  Or download from: https://www.python.org/downloads/"
        fi
    else
        print_error "Python3 not found"
        print_info "Please install Python 3.11+:"
        print_info "  macOS: brew install python@3.11"
        print_info "  Ubuntu: sudo apt install python3.11"
        print_info "  Or download from: https://www.python.org/downloads/"
    fi
    
    # Check for pip
    if command_exists pip3; then
        print_success "pip3 found"
    else
        print_error "pip3 not found"
        print_info "Install pip3 with: python3 -m ensurepip --upgrade"
    fi
}

# Function to check Git installation
check_git() {
    print_header "Checking Git Installation"
    
    if command_exists git; then
        GIT_VERSION=$(git --version | cut -d' ' -f3)
        print_success "Git $GIT_VERSION found"
        
        # Check git configuration
        if git config --global user.name >/dev/null 2>&1 && git config --global user.email >/dev/null 2>&1; then
            print_success "Git user configuration found"
        else
            print_warning "Git user not configured"
            print_info "Configure git with:"
            print_info "  git config --global user.name 'Your Name'"
            print_info "  git config --global user.email 'your.email@example.com'"
        fi
    else
        print_error "Git not found"
        print_info "Please install Git:"
        print_info "  macOS: brew install git"
        print_info "  Ubuntu: sudo apt install git"
        print_info "  Or download from: https://git-scm.com/downloads"
    fi
}

# Function to check Docker installation and status
check_docker() {
    print_header "Checking Docker Installation and Status"
    
    if command_exists docker; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        print_success "Docker $DOCKER_VERSION found"
        
        # Check if Docker daemon is running
        if docker info >/dev/null 2>&1; then
            print_success "Docker daemon is running"
        else
            print_error "Docker daemon is not running"
            print_info "Start Docker with:"
            print_info "  macOS: Open Docker Desktop"
            print_info "  Linux: sudo systemctl start docker"
            
            # Attempt to start Docker on macOS
            if [[ "$OSTYPE" == "darwin"* ]]; then
                print_info "Attempting to start Docker Desktop..."
                if [ -d "/Applications/Docker.app" ]; then
                    open -a Docker
                    print_fix "Docker Desktop startup initiated"
                    print_info "Please wait for Docker to start (may take 30-60 seconds)"
                    
                    # Wait for Docker to start (up to 60 seconds)
                    for i in {1..12}; do
                        if docker info >/dev/null 2>&1; then
                            print_success "Docker daemon is now running"
                            break
                        fi
                        sleep 5
                        echo -n "."
                    done
                    echo ""
                else
                    print_info "Docker Desktop not found in /Applications/Docker.app"
                    print_info "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
                fi
            fi
        fi
    else
        print_error "Docker not found"
        print_info "Please install Docker:"
        print_info "  macOS: Download Docker Desktop from https://www.docker.com/products/docker-desktop"
        print_info "  Ubuntu: curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
    fi
}

# Function to check ridges repository
check_ridges_repo() {
    print_header "Checking Ridges Repository"
    
    RIDGES_PATH="../ridges"
    if [ -d "$RIDGES_PATH" ]; then
        print_success "Ridges directory found at $RIDGES_PATH"
        
        # Check if it's a git repository
        if [ -d "$RIDGES_PATH/.git" ]; then
            print_success "Ridges is a git repository"
            
            # Check git status
            cd "$RIDGES_PATH"
            CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
            print_info "Current branch: $CURRENT_BRANCH"
            
            # Check for uncommitted changes
            if [ -n "$(git status --porcelain)" ]; then
                print_warning "Ridges repository has uncommitted changes"
            else
                print_success "Ridges repository is clean"
            fi
            cd - >/dev/null
        else
            print_error "Ridges directory exists but is not a git repository"
            print_info "Clone the ridges repository to the parent directory:"
            print_info "  cd .. && git clone https://github.com/ridgesai/ridges.git ridges"
        fi
    else
        print_error "Ridges directory not found at $RIDGES_PATH"
        print_info "Clone the ridges repository to the parent directory:"
        print_info "  cd .. && git clone https://github.com/ridgesai/ridges.git ridges"
        
        # Offer to clone the official ridges repository
        read -p "Would you like me to clone the official ridges repository? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            REPO_URL="https://github.com/ridgesai/ridges.git"
            print_info "Cloning ridges repository from $REPO_URL..."
            cd ..
            if git clone "$REPO_URL" ridges; then
                print_fix "Ridges repository cloned successfully"
                cd ridges-agent-workbench
            else
                print_error "Failed to clone ridges repository"
                print_info "You can manually clone it with: cd .. && git clone $REPO_URL ridges"
                cd ridges-agent-workbench
            fi
        fi
    fi
}

# Function to check virtual environment in ridges
check_ridges_venv() {
    print_header "Checking Ridges Virtual Environment"
    
    RIDGES_PATH="../ridges"
    VENV_PATH="$RIDGES_PATH/.venv-linux"
    
    if [ -d "$RIDGES_PATH" ]; then
        if [ -d "$VENV_PATH" ]; then
            print_success "Virtual environment found at $VENV_PATH"
            
            # Check if virtual environment is functional
            if [ -f "$VENV_PATH/bin/activate" ]; then
                print_success "Virtual environment activation script found"
                
                # Try to activate and check Python
                if source "$VENV_PATH/bin/activate" && python --version >/dev/null 2>&1; then
                    VENV_PYTHON_VERSION=$(python --version 2>&1 | cut -d' ' -f2)
                    print_success "Virtual environment Python: $VENV_PYTHON_VERSION"
                    deactivate 2>/dev/null || true
                else
                    print_error "Virtual environment appears to be corrupted"
                    print_info "Recreate the virtual environment in ridges directory:"
                    print_info "  cd ../ridges && python3 -m venv .venv-linux"
                fi
            else
                print_error "Virtual environment activation script not found"
            fi
        else
            print_error "Virtual environment not found at $VENV_PATH"
            print_info "Create virtual environment in ridges directory:"
            print_info "  cd ../ridges && python3 -m venv .venv-linux"
            
            # Offer to create virtual environment
            if [ -d "$RIDGES_PATH" ]; then
                read -p "Would you like me to create the virtual environment? (y/n): " -n 1 -r
                echo ""
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    print_info "Creating virtual environment..."
                    cd "$RIDGES_PATH"
                    if python3 -m venv .venv-linux; then
                        print_fix "Virtual environment created successfully"
                    else
                        print_error "Failed to create virtual environment"
                    fi
                    cd - >/dev/null
                fi
            fi
        fi
    else
        print_error "Cannot check virtual environment - ridges directory not found"
    fi
}

# Function to check API key configuration
check_api_key() {
    print_header "Checking Chutes API Key Configuration"
    
    ENV_FILE="../ridges/proxy/.env"
    
    if [ -f "$ENV_FILE" ]; then
        print_success "Environment file found at $ENV_FILE"
        
        # Check for API key (without revealing it)
        if grep -q "CHUTES_API_KEY=" "$ENV_FILE" && [ -n "$(grep "CHUTES_API_KEY=" "$ENV_FILE" | cut -d'=' -f2)" ]; then
            print_success "Chutes API key found in environment file"
        else
            print_error "Chutes API key not found or empty in $ENV_FILE"
            print_info "Add your Chutes API key to $ENV_FILE:"
            print_info "  echo 'CHUTES_API_KEY=your_api_key_here' >> $ENV_FILE"
        fi
    else
        print_error "Environment file not found at $ENV_FILE"
        
        # Check if proxy directory exists
        PROXY_DIR="../ridges/proxy"
        if [ -d "$PROXY_DIR" ]; then
            print_info "Creating environment file at $ENV_FILE"
            print_info "Add your Chutes API key:"
            print_info "  echo 'CHUTES_API_KEY=your_api_key_here' > $ENV_FILE"
            
            # Offer to create the file
            read -p "Would you like me to create the .env file template? (y/n): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                mkdir -p "$PROXY_DIR"
                echo "# Chutes API Configuration" > "$ENV_FILE"
                echo "# Replace 'your_api_key_here' with your actual API key" >> "$ENV_FILE"
                echo "CHUTES_API_KEY=your_api_key_here" >> "$ENV_FILE"
                print_fix "Environment file template created at $ENV_FILE"
                print_info "Please edit the file and add your actual API key"
            fi
        else
            print_error "Proxy directory not found at $PROXY_DIR"
            print_info "Ensure the ridges repository is properly cloned with all directories"
        fi
    fi
}

# Function to check ridges.py script
check_ridges_script() {
    print_header "Checking Ridges Script"
    
    RIDGES_SCRIPT="../ridges/ridges.py"
    
    if [ -f "$RIDGES_SCRIPT" ]; then
        print_success "Ridges script found at $RIDGES_SCRIPT"
        
        # Check if script is executable
        if [ -x "$RIDGES_SCRIPT" ]; then
            print_success "Ridges script is executable"
        else
            print_warning "Ridges script is not executable"
            print_info "Make it executable with: chmod +x $RIDGES_SCRIPT"
        fi
    else
        print_error "Ridges script not found at $RIDGES_SCRIPT"
        print_info "Ensure the ridges repository is properly cloned"
    fi
}

# Function to run a basic connectivity test
test_basic_functionality() {
    print_header "Testing Basic Functionality"
    
    RIDGES_PATH="../ridges"
    
    if [ -d "$RIDGES_PATH" ] && [ -f "$RIDGES_PATH/ridges.py" ] && [ -d "$RIDGES_PATH/.venv-linux" ]; then
        print_info "Running basic ridges.py test..."
        cd "$RIDGES_PATH"
        
        if source .venv-linux/bin/activate; then
            # Try to run ridges.py help command
            if python ridges.py --help >/dev/null 2>&1; then
                print_success "Ridges script is functional"
            else
                print_warning "Ridges script may have dependency issues"
                print_info "Try installing dependencies with: pip install -r requirements.txt"
            fi
            deactivate 2>/dev/null || true
        else
            print_error "Could not activate virtual environment"
        fi
        
        cd - >/dev/null
    else
        print_warning "Skipping functionality test - missing components"
    fi
}

# Main execution
main() {
    print_header "Ridges Agent Workbench - Setup Verification"
    print_info "This script will check all prerequisites and attempt to fix common issues."
    print_info "Working directory: $(pwd)"
    
    # Run all checks
    check_python
    check_git
    check_docker
    check_ridges_repo
    check_ridges_venv
    check_api_key
    check_ridges_script
    test_basic_functionality
    
    # Summary
    print_header "Setup Verification Summary"
    
    if [ $ISSUES_FOUND -eq 0 ]; then
        print_success "All checks passed! Your setup appears to be ready."
        print_info "You can now run: bash scripts/run_agent_test.sh"
    else
        print_warning "Found $ISSUES_FOUND issue(s) that need attention."
        if [ $FIXES_APPLIED -gt 0 ]; then
            print_info "Applied $FIXES_APPLIED automatic fix(es)."
        fi
        print_info "Please review the issues above and follow the suggested solutions."
    fi
    
    echo -e "\n${BLUE}For more information, see the README.md file.${NC}"
}

# Run main function
main "$@"
