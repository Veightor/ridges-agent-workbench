# Ridges Agent Workbench - Complete Setup Guide

This guide will help you complete the ridges environment setup for full functionality.

## 🎯 Current Status

✅ **Workbench Infrastructure**: Complete and working  
✅ **Scripts and Tools**: All functional  
✅ **Documentation**: Complete  
✅ **API Key**: Configured  
⏳ **Ridges Dependencies**: Needs installation  

## 🔧 Complete Setup Steps

### Step 1: Verify Current Setup

First, run the verification script to confirm everything is ready:

```bash
cd ridges-agent-workbench
python verify_setup.py
```

**Expected Result**: 6/6 checks should pass (except ridges dependencies)

### Step 2: Install Ridges Dependencies

Navigate to the ridges directory and install dependencies:

```bash
cd ../ridges
python -m pip install -e .
```

**Note**: This may take 5-10 minutes as it downloads and installs many dependencies including:
- aioboto3
- asyncpg
- boto
- datadog-api-client
- fiber
- And many others...

### Step 3: Verify Ridges CLI

Test that the ridges CLI is working:

```bash
cd ../ridges
./ridges.py --help
```

**Expected Result**: Should show CLI help with available commands

### Step 4: Test Full Pipeline

Run a complete test with the workbench:

```bash
cd ../ridges-agent-workbench
scripts\run_agent_test.bat ..\ridges\miner\top_agent_tmp.py
```

**Expected Result**: Should run the actual ridges test-agent command

## 🚨 Troubleshooting

### Issue: Installation Fails or Hangs

**Solution 1**: Install dependencies individually:
```bash
cd ../ridges
python -m pip install click coverage datadog-api-client
python -m pip install aioboto3 asyncpg boto
python -m pip install -e .
```

**Solution 2**: Use requirements.txt:
```bash
cd ../ridges
python -m pip install -r requirements.txt
```

**Solution 3**: Create virtual environment:
```bash
cd ../ridges
python -m venv venv
venv\Scripts\activate
python -m pip install -e .
```

### Issue: PowerShell Execution Policy

If you get execution policy errors:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue: Python Version

Ensure you're using Python 3.11+:
```bash
python --version
```

If needed, install Python 3.11 from python.org

## ✅ Verification Checklist

After completing setup, verify everything works:

- [ ] `python verify_setup.py` shows 6/6 checks passed
- [ ] `./ridges.py --help` shows CLI help
- [ ] `scripts\run_agent_test.bat` runs without errors
- [ ] New test run is created in `runs/` directory
- [ ] Run log contains actual ridges output (not just errors)

## 🎯 Expected Final State

Once complete, you should have:

1. **Fully functional workbench** with all scripts working
2. **Working ridges CLI** that can communicate with Chutes
3. **Complete test pipeline** from agent file to results
4. **All verification checks passing**

## 📞 Support

If you encounter issues:

1. Check the `CHECKS.md` file for troubleshooting steps
2. Review the error messages in `runs/*/run.log`
3. Ensure all prerequisites are met (Python 3.11+, API key, etc.)
4. Try the alternative installation methods above

## 🚀 Ready to Use

Once setup is complete, your team can:

- Test any agent using the wrapper scripts
- Generate timestamped test runs
- Save and analyze results locally
- Use the workbench for agent development and testing

The workbench is designed to be the exact same environment that validators use on the network, giving you local testing capabilities before submission.
