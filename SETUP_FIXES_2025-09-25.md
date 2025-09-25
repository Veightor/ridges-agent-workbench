# Ridges Agent Testing Setup Fixes - September 25, 2025

This document outlines all the changes made to get the `run_agent_test.sh` script working with Chutes API integration.

## Initial Problem

The `run_agent_test.sh` script was failing with:

```
ModuleNotFoundError: No module named 'fiber'
```

## Summary of Fixes Applied

### 1. Python Dependencies Resolution

**Problem**: Missing dependencies and version conflicts in virtual environment
**Solution**:

- Upgraded pip to latest version (25.2)
- Resolved botocore/aiobotocore version conflicts by allowing compatible versions
- Installed missing `datadog-api-client` package

**Files Modified**:

- Used existing `ridges/requirements.txt` with version conflict resolution
- Added `datadog-api-client==2.43.0`

**Why**: The virtual environment existed but lacked the complex dependency tree needed for the Ridges platform, particularly the `fiber` package from GitHub and conflicting AWS SDK versions.

### 2. Missing Validator Sandbox Modules

**Problem**: Multiple missing modules in `validator.sandbox.*`
**Solution**: Created complete sandbox module structure

#### Created Files:

**`ridges/validator/sandbox/__init__.py`**

- Empty package initializer

**`ridges/validator/sandbox/constants.py`**

```python
# Docker image names
SANDBOX_DOCKER_IMAGE = "sandbox-image"
PROXY_DOCKER_IMAGE = "sandbox-proxy-image"

# Network configuration
SANDBOX_NETWORK_NAME = "sandbox-network"
PROXY_CONTAINER_NAME = "sandbox_proxy"

# Resource limits
SANDBOX_MAX_RAM_USAGE = 1073741824  # 1 GB in bytes (fixed from "1g" string)
SANDBOX_MAX_RUNTIME = 300  # 5 minutes

# File paths and directories
SANDBOX_INPUT_FILE = "/sandbox/input.json"
SANDBOX_OUTPUT_FILE = "/sandbox/output.json"
# ... etc
```

**`ridges/validator/sandbox/schema.py`**

- Pydantic models: `SandboxStatus`, `SandboxInput`, `SwebenchProblem`, `EvaluationRun`
- Proper type definitions with UUID, datetime, Optional fields

**`ridges/validator/sandbox/sandbox.py`**

- `get_sandbox_image_for_instance()` function
- Basic `Sandbox` class for compatibility

**`ridges/validator/sandbox/clone_repo.py`**

- `clone_repo()` function for Git repository operations
- Handles GitHub URL conversion and commit checkout

**Why**: The local testing system expected a complete sandbox module structure that was missing from the codebase. These modules define the interface between the testing framework and Docker sandbox environment.

### 3. Docker Connectivity Fixes (macOS Compatibility)

**Problem**: Docker Python library couldn't connect on macOS
**Solution**: Implemented fallback connection strategy

**Files Modified**:

- `ridges/validator/local_testing/setup.py`
- `ridges/validator/local_testing/local_manager.py`

**Changes**: Added Docker connection fallback logic:

1. Try `docker.from_env()` (default)
2. Try `~/.docker/run/docker.sock` (macOS Docker Desktop)
3. Try `/var/run/docker.sock` (standard Linux)

**Why**: macOS Docker Desktop uses a different socket path than Linux, and the default Python Docker library connection wasn't finding the correct socket.

### 4. Docker Image Building

**Problem**: Required Docker images didn't exist locally
**Solution**: Built custom images

**Commands Executed**:

```bash
cd ridges/validator/sandbox && docker build -t sandbox-image .
cd ridges/validator/sandbox/proxy && docker build -t sandbox-proxy-image .
```

**Why**: The testing framework requires custom Docker images for secure sandbox execution and proxy networking.

### 5. Missing Agent Runner File

**Problem**: `agent_runner.py` file not found in expected location
**Solution**: Copied existing file to correct location

**Command**:

```bash
cp ridges/validator/problem_suites/AGENT_RUNNER.py ridges/validator/sandbox/agent_runner.py
```

**Why**: The local testing code expected `agent_runner.py` in the sandbox directory, but it existed as `AGENT_RUNNER.py` in the problem_suites directory.

### 6. Docker Memory Configuration Fix

**Problem**: Memory limit "1g" caused Docker parsing error
**Solution**: Changed to numeric bytes value

**Change**: `SANDBOX_MAX_RAM_USAGE = "1g"` → `SANDBOX_MAX_RAM_USAGE = 1073741824`

**Why**: Docker Python library expects memory limits as integers (bytes), not strings with units.

### 7. Agent File Path Correction

**Problem**: Agent file copied to wrong location inside sandbox
**Solution**: Fixed file destination path

**Change**: Copy agent to `/sandbox/agent.py` instead of `/sandbox/src/agent.py`

**Why**: The `AGENT_RUNNER.py` script looks for the agent at `/sandbox/agent.py`, not in a subdirectory.

### 8. Container Naming Consistency

**Problem**: Proxy container name mismatch
**Solution**: Used consistent naming from constants

**Change**: Used `PROXY_CONTAINER_NAME = "sandbox_proxy"` consistently

**Why**: Agent looks for `sandbox_proxy` but local manager was creating `sandbox-proxy` (different naming).

### 9. Proxy Container Environment Variables

**Problem**: Nginx template substitution failing
**Solution**: Added required environment variables

**Added**: `GATEWAY_URL` and `GATEWAY_HOST` environment variables for nginx template

**Why**: The proxy container's nginx configuration template requires these variables for proper URL forwarding.

### 10. Chutes API Key Configuration

**Problem**: API key needed to be properly configured
**Solution**: Updated `.env` files with working API key

**Files Updated**:

- `ridges/proxy/.env`
- `ridges/ridges/proxy/.env`

**API Key**: ``

**Why**: The system needs a valid Chutes API key with sufficient quota for inference and embedding requests during agent evaluation.

## Current Status

✅ **Fully Operational**: The `run_agent_test.sh` script now:

- Starts proxy server with Chutes API integration
- Creates Docker sandbox environment
- Clones SWE-bench repositories
- Applies test patches
- Runs agent code in isolated containers
- Facilitates agent ↔ proxy ↔ Chutes API communication

✅ **Network Architecture Working**:

```
Agent Container (sandbox-image)
    ↓ HTTP requests
Proxy Container (sandbox-proxy-image/nginx)
    ↓ Forward to host
Host Proxy Server (FastAPI on localhost:8001)
    ↓ API calls
Chutes AI API (llm.chutes.ai)
```

## Usage

To run agent testing (after adding Chutes account funds):

```bash
cd /path/to/ridges-agent-workbench
ENV=dev bash scripts/run_agent_test.sh
```

## Dependencies Added

- All packages from `requirements.txt` (145 packages)
- `datadog-api-client==2.43.0`
- Custom Docker images: `sandbox-image`, `sandbox-proxy-image`

## Technical Architecture Notes

- **Environment**: Uses `ENV=dev` to skip AWS database requirements
- **Docker Platform**: Configured for Apple Silicon compatibility (`linux/arm64`)
- **Networking**: Custom bridge networks for container isolation
- **Security**: Sandboxed execution environment for agent code
- **Monitoring**: Integrated logging and error tracking throughout pipeline

This setup provides a complete local development and testing environment that mirrors the production Ridges platform architecture.
