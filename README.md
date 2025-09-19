# Ridges Agent Test Workbench

A local testing environment for Ridges agents that allows you to test agents locally while compute runs on Chutes servers.

## Overview

This workbench provides a clean, repeatable way to:
- Load any agent file
- Run it through the official test-agent tool (which calls Chutes)
- Save results locally for the team

## Prerequisites

- Python 3.11+ (Python 3.13 works as well)
- Local `ridges/` repository cloned and set up
- Chutes API key configured in `ridges/proxy/.env`

## ⚠️ Setup Status

**Current Status**: Workbench infrastructure complete, ridges dependencies need installation

- ✅ **Workbench**: Fully functional
- ✅ **Scripts**: Working (creates runs, saves metadata)
- ✅ **Documentation**: Complete
- ✅ **API Key**: Configured
- ⏳ **Ridges Dependencies**: Need installation for full functionality

**Next Step**: Follow `SETUP_GUIDE.md` to complete ridges environment setup

## Quick Start

1. **Set up the Ridges repo** (if not already done):
   ```bash
   git clone https://github.com/ridgesai/ridges
   cd ridges
   python -m venv venv
   # Activate virtual environment
   # Windows: venv\Scripts\activate
   # Linux/Mac: source venv/bin/activate
   pip install -e .
   cp proxy/.env.example proxy/.env
   # Edit proxy/.env and add your CHUTES_API_KEY
   ```

2. **Get a test agent**:
   - Go to https://www.ridges.ai/explore
   - Enable "Open agents"
   - Pick a top Open agent (e.g., aurora)
   - Copy the code and save as `ridges/miner/top_agent_tmp.py`

3. **Run a test**:
   ```bash
   bash scripts/run_agent_test.sh
   ```

## Usage

### Basic Test Run
```bash
bash scripts/run_agent_test.sh
```

### Custom Test Run
```bash
bash scripts/run_agent_test.sh [agent_path] [num_problems] [problem_set] [timeout]
```

**Parameters:**
- `agent_path`: Path to agent file (default: `../ridges/miner/top_agent_tmp.py`)
- `num_problems`: Number of problems to test (default: 1)
- `problem_set`: Problem difficulty (default: easy)
- `timeout`: Timeout in seconds (default: 300)

### Example Runs
```bash
# Test with 2 medium problems, 15-minute timeout
bash scripts/run_agent_test.sh ../ridges/miner/top_agent_tmp.py 2 medium 900

# Test with custom agent file
bash scripts/run_agent_test.sh ../my_agent.py 3 hard 600
```

## Output

Test results are saved in timestamped directories under `runs/`:
- `runs/<timestamp>/meta.txt` - Test parameters
- `runs/<timestamp>/git_commit.txt` - Git commit info from ridges repo
- `runs/<timestamp>/run.log` - Full test output

## Important Notes

- **This is a testing/benchmarking tool only** - not for agent improvement
- All compute runs on Chutes servers, not locally
- Only files and logs are stored locally
- Agents must define `agent_main(input_dict)` returning `{"patch": "...diff..."}`
- No outbound network access except proxy endpoints

## Troubleshooting

See `CHECKS.md` for quick sanity tests to verify your setup.

## Contributing

This workbench is designed for team use. Feel free to submit issues or improvements via GitHub.

