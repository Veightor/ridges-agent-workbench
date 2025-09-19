# Ridges Agent Workbench - Sanity Checks

Use this checklist to verify your workbench setup is working correctly.

## Prerequisites Check

### 1. Python Version
```bash
python --version
```
**Expected**: Python 3.11+ (Python 3.13 works as well)
**Status**: [ ] ✅ Working / [ ] ❌ Issue

### 2. Ridges Repository Setup
```bash
cd ../ridges
ls ridges.py
```
**Expected**: `ridges.py` file exists
**Status**: [ ] ✅ Working / [ ] ❌ Issue

### 3. Ridges CLI Help
```bash
cd ../ridges
./ridges.py --help
```
**Expected**: Shows CLI help with available commands
**Status**: [ ] ✅ Working / [ ] ❌ Issue

### 4. Chutes API Key
```bash
cd ../ridges
ls proxy/.env
cat proxy/.env | grep CHUTES_API_KEY
```
**Expected**: `.env` file exists and contains `CHUTES_API_KEY=your_key_here`
**Status**: [ ] ✅ Working / [ ] ❌ Issue

## Agent File Check

### 5. Test Agent File
```bash
cd ../ridges
ls miner/top_agent_tmp.py
```
**Expected**: `top_agent_tmp.py` file exists
**Status**: [ ] ✅ Working / [ ] ❌ Issue

### 6. Agent Function Check
```bash
cd ../ridges
python -c "import sys; sys.path.append('.'); from miner.top_agent_tmp import agent_main; print('agent_main function found')"
```
**Expected**: No errors, prints "agent_main function found"
**Status**: [ ] ✅ Working / [ ] ❌ Issue

## Workbench Scripts Check

### 7. Wrapper Script (Linux/Mac)
```bash
bash scripts/run_agent_test.sh --help
```
**Expected**: Shows usage information
**Status**: [ ] ✅ Working / [ ] ❌ Issue

### 8. Wrapper Script (Windows)
```cmd
scripts\run_agent_test.bat
```
**Expected**: Runs without errors, creates runs directory
**Status**: [ ] ✅ Working / [ ] ❌ Issue

## Test Run Check

### 9. Basic Test Run
```bash
bash scripts/run_agent_test.sh
```
**Expected**: 
- Creates `runs/<timestamp>/` directory
- Generates `meta.txt`, `git_commit.txt`, `run.log`
- Shows test progress
**Status**: [ ] ✅ Working / [ ] ❌ Issue

### 10. Log File Check
```bash
ls runs/*/run.log
tail -20 runs/*/run.log
```
**Expected**: 
- Log file exists
- Contains test output or error messages
- Ends with summary or error
**Status**: [ ] ✅ Working / [ ] ❌ Issue

## Troubleshooting

### Common Issues

**Issue**: `./ridges.py --help` not working
**Solution**: 
1. Ensure you're in the ridges directory
2. Check if virtual environment is activated
3. Install dependencies: `pip install -e .`

**Issue**: `CHUTES_API_KEY` not found
**Solution**:
1. Copy `proxy/.env.example` to `proxy/.env`
2. Add your API key: `CHUTES_API_KEY=your_key_here`

**Issue**: Agent file not found
**Solution**:
1. Go to https://www.ridges.ai/explore
2. Enable "Open agents"
3. Copy agent code to `ridges/miner/top_agent_tmp.py`

**Issue**: Test run fails
**Solution**:
1. Check ridges setup is complete
2. Verify API key is valid
3. Check agent file has `agent_main` function

## Quick Fix Commands

```bash
# Reset and reinstall ridges
cd ../ridges
rm -rf venv
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -e .

# Test basic functionality
./ridges.py --help
```

## Success Criteria

All checks should show ✅ for a fully working workbench.

**Minimum for basic functionality**: Checks 1, 2, 5, 7/8, 9
**Full functionality**: All checks ✅
