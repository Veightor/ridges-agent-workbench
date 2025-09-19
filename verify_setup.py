#!/usr/bin/env python3
"""
Ridges Agent Workbench - Pre-Handback Verification Script
This script checks if all assignments from the workflow are completed.
"""

import os
import sys
import subprocess
from pathlib import Path

def print_status(check_name, status, details=""):
    """Print check status with emoji"""
    emoji = "✅" if status else "❌"
    print(f"{emoji} {check_name}")
    if details:
        print(f"   {details}")

def check_file_exists(file_path, description):
    """Check if a file exists"""
    exists = os.path.exists(file_path)
    print_status(description, exists, f"Path: {file_path}")
    return exists

def check_directory_structure():
    """Check if all required directories exist"""
    print("\n📁 DIRECTORY STRUCTURE CHECK")
    print("=" * 50)
    
    workbench_dir = Path(".")
    required_dirs = ["scripts", "runs"]
    
    all_good = True
    for dir_name in required_dirs:
        dir_path = workbench_dir / dir_name
        exists = dir_path.exists() and dir_path.is_dir()
        print_status(f"Directory: {dir_name}", exists)
        if not exists:
            all_good = False
    
    return all_good

def check_required_files():
    """Check if all required files exist"""
    print("\n📄 REQUIRED FILES CHECK")
    print("=" * 50)
    
    required_files = [
        ("README.md", "Main documentation"),
        (".gitignore", "Git ignore file"),
        ("CHECKS.md", "Sanity checks guide"),
        ("scripts/run_agent_test.sh", "Bash wrapper script"),
        ("scripts/run_agent_test.bat", "Windows wrapper script"),
        ("sample_agent.py", "Sample agent for testing"),
        ("runs/.gitkeep", "Runs directory placeholder")
    ]
    
    all_good = True
    for file_path, description in required_files:
        exists = check_file_exists(file_path, description)
        if not exists:
            all_good = False
    
    return all_good

def check_agent_file():
    """Check if the test agent exists"""
    print("\n🤖 AGENT FILE CHECK")
    print("=" * 50)
    
    agent_path = "../ridges/miner/top_agent_tmp.py"
    exists = check_file_exists(agent_path, "Test agent file")
    
    if exists:
        # Check if agent has required function
        try:
            with open(agent_path, 'r') as f:
                content = f.read()
                has_agent_main = "def agent_main(" in content
                has_return_patch = 'return {"patch":' in content or '"patch":' in content
                
                print_status("Has agent_main function", has_agent_main)
                print_status("Returns patch format", has_return_patch)
                
                return has_agent_main and has_return_patch
        except Exception as e:
            print_status("Agent file readable", False, f"Error: {e}")
            return False
    
    return False

def check_ridges_setup():
    """Check if ridges environment is set up"""
    print("\n🔧 RIDGES SETUP CHECK")
    print("=" * 50)
    
    ridges_dir = Path("../ridges")
    ridges_py = ridges_dir / "ridges.py"
    env_file = ridges_dir / "proxy" / ".env"
    
    has_ridges = check_file_exists(str(ridges_py), "Ridges CLI script")
    has_env = check_file_exists(str(env_file), "Environment file")
    
    # Check if .env has API key
    has_api_key = False
    if has_env:
        try:
            with open(env_file, 'r') as f:
                content = f.read()
                has_api_key = "CHUTES_API_KEY=" in content and "CHUTES_API_KEY=\n" not in content
                print_status("API key configured", has_api_key)
        except Exception as e:
            print_status("API key configured", False, f"Error reading .env: {e}")
    
    return has_ridges and has_env and has_api_key

def check_git_repo():
    """Check if git repository is properly set up"""
    print("\n📦 GIT REPOSITORY CHECK")
    print("=" * 50)
    
    try:
        # Check if we're in a git repo
        result = subprocess.run(["git", "status"], capture_output=True, text=True)
        is_git_repo = result.returncode == 0
        print_status("Git repository initialized", is_git_repo)
        
        if is_git_repo:
            # Check if remote is set
            result = subprocess.run(["git", "remote", "-v"], capture_output=True, text=True)
            has_remote = "origin" in result.stdout
            print_status("Remote origin configured", has_remote)
            
            # Check if there are commits
            result = subprocess.run(["git", "log", "--oneline", "-1"], capture_output=True, text=True)
            has_commits = result.returncode == 0 and result.stdout.strip()
            print_status("Has commits", has_commits)
            
            return is_git_repo and has_remote and has_commits
        
    except Exception as e:
        print_status("Git repository check", False, f"Error: {e}")
    
    return False

def check_test_runs():
    """Check if test runs have been generated"""
    print("\n🧪 TEST RUNS CHECK")
    print("=" * 50)
    
    runs_dir = Path("runs")
    if not runs_dir.exists():
        print_status("Runs directory exists", False)
        return False
    
    # Find run directories (excluding .gitkeep)
    run_dirs = [d for d in runs_dir.iterdir() if d.is_dir()]
    has_runs = len(run_dirs) > 0
    print_status("Test runs generated", has_runs, f"Found {len(run_dirs)} run(s)")
    
    if has_runs:
        # Check latest run has required files
        latest_run = max(run_dirs, key=os.path.getctime)
        required_files = ["meta.txt", "git_commit.txt", "run.log"]
        
        for file_name in required_files:
            file_path = latest_run / file_name
            exists = check_file_exists(str(file_path), f"Latest run has {file_name}")
    
    return has_runs

def main():
    """Run all verification checks"""
    print("🔍 RIDGES AGENT WORKBENCH - VERIFICATION CHECK")
    print("=" * 60)
    print("Checking if all workflow assignments are completed...")
    
    checks = [
        ("Directory Structure", check_directory_structure),
        ("Required Files", check_required_files),
        ("Agent File", check_agent_file),
        ("Ridges Setup", check_ridges_setup),
        ("Git Repository", check_git_repo),
        ("Test Runs", check_test_runs)
    ]
    
    results = []
    for check_name, check_func in checks:
        try:
            result = check_func()
            results.append((check_name, result))
        except Exception as e:
            print_status(f"{check_name} (Error)", False, f"Exception: {e}")
            results.append((check_name, False))
    
    # Summary
    print("\n" + "=" * 60)
    print("📊 VERIFICATION SUMMARY")
    print("=" * 60)
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for check_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} {check_name}")
    
    print(f"\n🎯 OVERALL: {passed}/{total} checks passed")
    
    if passed == total:
        print("🎉 ALL CHECKS PASSED! Ready for hand-back!")
        return True
    else:
        print("⚠️  Some checks failed. Please review and fix before hand-back.")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
