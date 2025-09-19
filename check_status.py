#!/usr/bin/env python3
"""
Ridges Agent Workbench - Status Check
Quick status check to see what's working and what needs setup.
"""

import os
import subprocess
from pathlib import Path

def check_status():
    """Check the current status of the workbench setup"""
    
    print("🔍 RIDGES AGENT WORKBENCH - STATUS CHECK")
    print("=" * 50)
    
    # Check workbench components
    print("\n📦 WORKBENCH COMPONENTS")
    print("-" * 30)
    
    workbench_checks = [
        ("README.md", "Main documentation"),
        ("CHECKS.md", "Sanity checks"),
        ("SETUP_GUIDE.md", "Setup instructions"),
        ("scripts/run_agent_test.bat", "Windows wrapper"),
        ("scripts/run_agent_test.sh", "Bash wrapper"),
        ("sample_agent.py", "Sample agent"),
        ("verify_setup.py", "Verification script")
    ]
    
    workbench_ok = True
    for file_path, description in workbench_checks:
        exists = os.path.exists(file_path)
        status = "✅" if exists else "❌"
        print(f"{status} {description}")
        if not exists:
            workbench_ok = False
    
    # Check ridges setup
    print("\n🔧 RIDGES SETUP")
    print("-" * 30)
    
    ridges_dir = Path("../ridges")
    ridges_py = ridges_dir / "ridges.py"
    env_file = ridges_dir / "proxy" / ".env"
    
    has_ridges = ridges_py.exists()
    has_env = env_file.exists()
    
    print(f"{'✅' if has_ridges else '❌'} Ridges CLI script")
    print(f"{'✅' if has_env else '❌'} Environment file")
    
    # Check API key
    has_api_key = False
    if has_env:
        try:
            with open(env_file, 'r') as f:
                content = f.read()
                has_api_key = "CHUTES_API_KEY=" in content and "CHUTES_API_KEY=\n" not in content
        except:
            pass
    
    print(f"{'✅' if has_api_key else '❌'} API key configured")
    
    # Check ridges dependencies
    print("\n🐍 RIDGES DEPENDENCIES")
    print("-" * 30)
    
    ridges_deps_ok = False
    if has_ridges:
        try:
            result = subprocess.run(["python", str(ridges_py), "--help"], 
                                  capture_output=True, text=True, timeout=10)
            ridges_deps_ok = result.returncode == 0
        except:
            pass
    
    print(f"{'✅' if ridges_deps_ok else '❌'} Ridges dependencies installed")
    
    # Check test runs
    print("\n🧪 TEST RUNS")
    print("-" * 30)
    
    runs_dir = Path("runs")
    has_runs = runs_dir.exists() and any(runs_dir.iterdir())
    print(f"{'✅' if has_runs else '❌'} Test runs generated")
    
    # Summary
    print("\n" + "=" * 50)
    print("📊 STATUS SUMMARY")
    print("=" * 50)
    
    if workbench_ok and has_ridges and has_env and has_api_key:
        if ridges_deps_ok:
            print("🎉 FULLY FUNCTIONAL - Ready to use!")
            print("   All components working, including ridges CLI")
        else:
            print("⚠️  WORKBENCH READY - Ridges dependencies need installation")
            print("   Follow SETUP_GUIDE.md to complete setup")
    else:
        print("❌ SETUP INCOMPLETE - Missing essential components")
        print("   Check the failed items above and fix them")
    
    print(f"\n📋 Next Steps:")
    if not ridges_deps_ok:
        print("   1. Follow SETUP_GUIDE.md to install ridges dependencies")
        print("   2. Run 'python verify_setup.py' to verify complete setup")
    else:
        print("   1. Run 'python verify_setup.py' for full verification")
        print("   2. Start testing agents with the workbench!")
    
    return workbench_ok and has_ridges and has_env and has_api_key

if __name__ == "__main__":
    check_status()
