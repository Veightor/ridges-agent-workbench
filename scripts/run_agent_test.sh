#!/bin/bash

# run_agent_test.sh - Automated agent testing with logging
# Usage: ./run_agent_test.sh [agent_path] [num_problems] [problem_set] [timeout]

set -e  # Exit on any error

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run setup verification first
echo "Running setup verification..."
if ! bash "${SCRIPT_DIR}/setup_check.sh"; then
    echo ""
    echo "=========================================="
    echo "Setup verification failed!"
    echo "Please resolve the critical issues above before running tests."
    echo "=========================================="
    exit 1
fi
echo ""

# Default arguments
DEFAULT_AGENT_PATH="miner/top_agent_tmp.py"
DEFAULT_NUM_PROBLEMS=1
DEFAULT_PROBLEM_SET="easy"
DEFAULT_TIMEOUT=300

# Parse command line arguments or use defaults
AGENT_PATH="${1:-$DEFAULT_AGENT_PATH}"
NUM_PROBLEMS="${2:-$DEFAULT_NUM_PROBLEMS}"
PROBLEM_SET="${3:-$DEFAULT_PROBLEM_SET}"
TIMEOUT="${4:-$DEFAULT_TIMEOUT}"

# Create timestamp for this run
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RUN_DIR="runs/${TIMESTAMP}"

echo "Creating run directory: ${RUN_DIR}"
mkdir -p "${RUN_DIR}"

# Save metadata about this run
echo "Saving run metadata..."
cat > "${RUN_DIR}/meta.txt" << EOF
Run Date: $(date)
Agent Path: ${AGENT_PATH}
Number of Problems: ${NUM_PROBLEMS}
Problem Set: ${PROBLEM_SET}
Timeout: ${TIMEOUT}s
EOF

# Get git commit info from ridges directory
echo "Capturing git commit information..."
if [ -d "../ridges/.git" ]; then
    cd ../ridges
    echo "Git Commit: $(git rev-parse HEAD)" > "../ridges-agent-workbench/${RUN_DIR}/git_commit.txt"
    echo "Git Branch: $(git branch --show-current)" >> "../ridges-agent-workbench/${RUN_DIR}/git_commit.txt"
    echo "Git Status:" >> "../ridges-agent-workbench/${RUN_DIR}/git_commit.txt"
    git status --porcelain >> "../ridges-agent-workbench/${RUN_DIR}/git_commit.txt"
    cd ../ridges-agent-workbench
else
    echo "Warning: ridges/.git not found, skipping git commit info"
    echo "Git info not available - ridges directory not found or not a git repo" > "${RUN_DIR}/git_commit.txt"
fi

# Run the test and capture output
echo "Starting agent test..."
echo "Command: python ridges.py test-agent --agent-file ${AGENT_PATH} --num-problems ${NUM_PROBLEMS} --problem-set ${PROBLEM_SET} --timeout ${TIMEOUT} --verbose"

cd ../ridges
source .venv-linux/bin/activate
python ridges.py test-agent \
    --agent-file "${AGENT_PATH}" \
    --num-problems "${NUM_PROBLEMS}" \
    --problem-set "${PROBLEM_SET}" \
    --timeout "${TIMEOUT}" \
    --verbose \
    2>&1 | tee "../ridges-agent-workbench/${RUN_DIR}/run.log"

cd ../ridges-agent-workbench

# Print summary
echo ""
echo "=========================================="
echo "Test run completed successfully!"
echo "Results saved to: ${RUN_DIR}"
echo "Files created:"
echo "  - meta.txt (run parameters)"
echo "  - git_commit.txt (git information)"
echo "  - run.log (complete test output)"
echo "=========================================="
