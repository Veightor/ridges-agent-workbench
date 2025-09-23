# Quick Sanity Checklist

Use this checklist to verify your Ridges Agent Workbench setup is working correctly before running evaluations.

## Prerequisites Check

Before running these checks, ensure you have:
- [ ] Python 3.11+ installed
- [ ] Docker running
- [ ] WSL2/Ubuntu environment (if on Windows)
- [ ] Virtual environment activated

## Core System Checks

### 1. Ridges CLI Functionality
```bash
cd ridges
python ridges.py --help
```

**Expected Output:**
- CLI help menu showing available commands
- Should include `test-agent`, `proxy`, `validator`, etc.

**Failure Signs:**
- `ModuleNotFoundError: No module named 'fiber'`
- `python: command not found`
- Import errors for other dependencies

### 2. API Key Configuration
```bash
cd ridges
cat proxy/.env | grep CHUTES_API_KEY
```

**Expected Output:**
```
CHUTES_API_KEY=your_actual_api_key_here
```

**Failure Signs:**
- File not found error
- Empty or missing API key value
- Placeholder text like `<provided_key>`

### 3. Agent Implementation Check
```bash
cd ridges
python -c "
from miner.top_agent_tmp import agent_main
test_input = {'problem_statement': 'test'}
result = agent_main(test_input)
print('Agent callable: True')
print('Return type:', type(result))
print('Has patch key:', 'patch' in result if isinstance(result, dict) else False)
if isinstance(result, dict) and 'patch' in result:
    print('Patch type:', type(result['patch']))
    print('Success: agent_main returns dict with patch key')
else:
    print('Error: Invalid return format')
"
```

**Expected Output:**
```
Agent callable: True
Return type: <class 'dict'>
Has patch key: True
Patch type: <class 'str'>
Success: agent_main returns dict with patch key
```

**Failure Signs:**
- Import errors
- Function not found
- Wrong return format (not dict or missing 'patch' key)
- Runtime errors in agent code

### 4. Test Run Verification
```bash
# Run a quick test
bash scripts/run_agent_test.sh

# After completion (or interruption), check the latest log
LATEST_RUN=$(ls -1t runs/ | head -1)
tail -10 runs/$LATEST_RUN/run.log
```

**Expected Output (last 10 lines should include):**
- Test completion summary with timing
- Individual results (pass/fail status)
- Cleanup messages (Docker containers removed)
- Summary statistics or error messages

**Examples of Good Endings:**
```
==========================================
Test run completed successfully!
Results saved to: runs/20250922_143052
Files created:
  - meta.txt (run parameters)
  - git_commit.txt (git information)
  - run.log (complete test output)
==========================================
```

Or with test results:
```
All 1 evaluations completed!
Total time: 108.3s
Results: 0/1 solved (0.0%)
Individual Results:
❌ psf__requests-5414: FAILED (11.1s)
🧹 Cleaning up...
🛑 Proxy stopped
```

**Failure Signs:**
- Hanging at "Uvicorn running on http://0.0.0.0:8001"
- Python not found errors
- Docker connection failures
- Incomplete logs without summary

## Troubleshooting Quick Fixes

### Check 1 Fails (CLI not working)
```bash
# Verify virtual environment
which python
python --version

# Reinstall dependencies if needed
cd ridges
pip install -e .
```

### Check 2 Fails (Missing API key)
```bash
cd ridges
cp proxy/.env.example proxy/.env
# Edit proxy/.env and add your API key
```

### Check 3 Fails (Agent issues)
```bash
# Check if agent file exists
ls -la ridges/miner/top_agent_tmp.py

# Verify file size (should be substantial, 100KB+)
du -h ridges/miner/top_agent_tmp.py
```

### Check 4 Fails (Test run issues)
```bash
# Check Docker status
docker ps

# Verify wrapper script permissions
ls -la scripts/run_agent_test.sh

# Check recent run directory was created
ls -la runs/
```

## All Checks Passed

If all checks pass, your workbench is ready for production use:

- ✅ Ridges CLI operational
- ✅ API authentication configured
- ✅ Agent properly implemented and callable
- ✅ Test runner creates complete logs with summaries

You can now run full evaluations with confidence that results will be properly captured and logged.

## Quick Test Command

Once all checks pass, run this for a final verification:

```bash
# Full test with verbose output
bash scripts/run_agent_test.sh miner/top_agent_tmp.py 1 easy 300

# Check results
LATEST=$(ls -1t runs/ | head -1)
echo "Latest run: $LATEST"
ls -la runs/$LATEST/
tail -5 runs/$LATEST/run.log
```

This should complete successfully and generate a timestamped run directory with all required files.# Quick Sanity Checklist

- [ ] `./ridges.py --help` works
- [ ] `proxy/.env` has key
- [ ] `agent_main` exists & returns "patch"
- [ ] `run.log` ends with summary

