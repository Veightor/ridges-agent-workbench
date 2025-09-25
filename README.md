# Ridges Agent Workbench

Personal workbench for working with the Ridges AI agent system and running reproducible local evaluations.

## Prerequisites

Before using this workbench, ensure you have:

- **Python 3.11+** installed and available
- **Local ridges repository** cloned and set up in the same directory as this workbench
- **Chutes API key** configured in `ridges/proxy/.env`
- **Docker** installed and running (required for local testing)
- **Git** for version control

## Project Structure

- `scripts/` - Automation scripts for testing and evaluation
  - `run_agent_test.sh` - Main wrapper script for reproducible agent testing
- `runs/` - Timestamped test results and logs (ignored by git)
- `ridges/` - Local copy of the Ridges repository
- `env.template` - Environment configuration template
- `README.md` - This documentation
- `.gitignore` - Git ignore configuration

## Getting Open Top Agents

### Step 1: Explore Available Agents

1. Access the Ridges platform or agent marketplace
2. Browse available open-source top agents via the Explore section
3. Review agent performance metrics and compatibility

### Step 2: Download Agent Code

1. Select a top-performing open agent from the available options
2. Copy the complete agent code (typically 300KB+ for production agents)
3. Save the code to `ridges/miner/top_agent_tmp.py`

### Step 3: Verify Agent Structure

Ensure the downloaded agent contains:

- `agent_main(input_dict)` function as the main entry point
- Proper error handling and return format: `{"patch": "...diff..."}`
- No unauthorized outbound network calls (only proxy endpoints allowed)

## Environment Configuration

The workbench includes a comprehensive environment template for easy configuration:

```bash
# Copy the template and customize with your values
cp env.template .env

# Edit .env with your actual API keys and preferences
nano .env
```

The template includes configuration for:

- **Chutes API Key**: Your API key from the Chutes platform
- **Testing Parameters**: Default values for agent testing
- **Docker Configuration**: Sandbox image settings
- **Development Options**: Debug mode, auto-updates, etc.

## Running Tests

### Basic Usage

```bash
# Run with default parameters (1 easy problem, 300s timeout)
bash scripts/run_agent_test.sh

# Run with custom parameters
bash scripts/run_agent_test.sh [agent_path] [num_problems] [problem_set] [timeout]
```

### Example Commands

```bash
# Test with defaults
bash scripts/run_agent_test.sh

# Test 2 medium problems with 15-minute timeout
bash scripts/run_agent_test.sh miner/top_agent_tmp.py 2 medium 900

# Test 5 easy problems with default timeout
bash scripts/run_agent_test.sh miner/top_agent_tmp.py 5 easy 300
```

### Parameters

- **agent_path**: Path to agent file (default: `miner/top_agent_tmp.py`)
- **num_problems**: Number of problems to test (default: `1`)
- **problem_set**: Difficulty level - `easy`, `medium`, or `hard` (default: `easy`)
- **timeout**: Timeout per problem in seconds (default: `300`)

## Test Results and Logs

### Where Logs Are Saved

All test results are automatically saved to timestamped directories:

```
runs/
├── 20250922_143052/     # Timestamp: YYYYMMDD_HHMMSS
│   ├── meta.txt         # Test parameters and run metadata
│   ├── git_commit.txt   # Git commit info for reproducibility
│   └── run.log          # Complete test output and results
└── 20250922_150234/     # Another test run
    ├── meta.txt
    ├── git_commit.txt
    └── run.log
```

### Log Contents

- **meta.txt**: Run parameters, timestamp, agent path, problem set details
- **git_commit.txt**: Git commit hash, branch, and repository status for reproducibility
- **run.log**: Complete test execution log including:
  - Test setup and configuration
  - Individual problem results
  - Performance metrics and timing
  - Error messages and debugging info
  - Cleanup and summary statistics

### Reading Results

```bash
# List all test runs
ls -la runs/

# View the last 20 lines of a specific test
tail -20 runs/20250922_143052/run.log

# Check test parameters
cat runs/20250922_143052/meta.txt

# Review git commit info for reproducibility
cat runs/20250922_143052/git_commit.txt
```

## Workflow Summary

1. **Setup**: Ensure prerequisites are installed and configured
2. **Get Agent**: Download open top agent code via Explore → save to `miner/top_agent_tmp.py`
3. **Test**: Run `bash scripts/run_agent_test.sh` with desired parameters
4. **Review**: Check timestamped results in `runs/` directory
5. **Compare**: Use logs to compare different agents or parameter configurations
6. **Reproduce**: Git commit tracking ensures tests can be reproduced exactly

## Important Notes

### Benchmarking Purpose Only

**This workbench is designed for processing and benchmarking agents only, not for agent improvement or development.**

- Use this system to evaluate and compare different open top agents
- Measure performance across different problem sets and configurations
- Generate reproducible benchmark results for analysis
- Track agent performance over time with consistent testing

### Not for Agent Development

- Do not use this workbench for modifying or improving agent code
- Agent development should be done in dedicated development environments
- This system focuses on evaluation and comparison of existing agents

### Data and Privacy

- Test results remain local to your system
- No agent code or results are shared externally without explicit action
- Git tracking ensures full reproducibility of benchmark results
- Logs contain detailed execution information for thorough analysis

## Troubleshooting

### Common Issues

**"Agent file not found"**

- Ensure agent file exists at the specified path
- Check that the path is relative to the ridges directory

**"Docker not running"**

- Start Docker Desktop or Docker service
- Verify Docker permissions for your user

**"Python command not found"**

- Ensure virtual environment is activated
- Check that Python 3.11+ is installed and accessible

**Test hangs at proxy startup**

- Check network connectivity to Chutes backend
- Verify API key is correctly configured in `ridges/proxy/.env`
- Ensure no firewall blocking required connections

### Getting Help

If you encounter issues:

1. Check the complete logs in `runs/[timestamp]/run.log`
2. Verify all prerequisites are properly installed
3. Ensure the ridges repository is properly set up
4. Confirm your Chutes API key is valid and correctly configured

## Version History

- **v0.1.0**: Initial release with automated testing wrapper and comprehensive logging

## Agent Source

**Agent Used**: Production ridges miner agent (agent.py → top_agent_tmp.py)  
**Source**: Built-in ridges repository agent code (120KB)  
**Location**: `ridges/miner/top_agent_tmp.py` (created from `ridges/miner/agent.py`)  
**Function**: `agent_main(input_dict)` returning `{"patch": "..."}`

**Note**: Instead of using the Explore dashboard, we used the existing production-ready agent code found in the ridges repository. This provides a more robust and tested agent implementation.
