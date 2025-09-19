#!/bin/bash

# Ridges Agent Test Runner
# Usage: run_agent_test.sh [agent_path] [num_problems] [problem_set] [timeout]

# Default values
AGENT_PATH="../ridges/miner/top_agent_tmp.py"
NUM_PROBLEMS=1
PROBLEM_SET="easy"
TIMEOUT=300

# Parse command line arguments
if [ $# -ge 1 ]; then
    AGENT_PATH="$1"
fi
if [ $# -ge 2 ]; then
    NUM_PROBLEMS="$2"
fi
if [ $# -ge 3 ]; then
    PROBLEM_SET="$3"
fi
if [ $# -ge 4 ]; then
    TIMEOUT="$4"
fi

# Create timestamp for this run
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RUN_DIR="runs/$TIMESTAMP"

# Create run directory
mkdir -p "$RUN_DIR"

# Save metadata
cat > "$RUN_DIR/meta.txt" << EOF
Agent Path: $AGENT_PATH
Number of Problems: $NUM_PROBLEMS
Problem Set: $PROBLEM_SET
Timeout: $TIMEOUT seconds
Timestamp: $TIMESTAMP
EOF

# Save git commit info from ridges repo
if [ -d "../ridges" ]; then
    cd ../ridges
    git log -1 --format="%H %s" > "../ridges-agent-workbench/$RUN_DIR/git_commit.txt"
    cd ../ridges-agent-workbench
else
    echo "Ridges repo not found" > "$RUN_DIR/git_commit.txt"
fi

# Run the test
echo "Starting Ridges agent test..."
echo "Agent: $AGENT_PATH"
echo "Problems: $NUM_PROBLEMS ($PROBLEM_SET)"
echo "Timeout: $TIMEOUT seconds"
echo "Run directory: $RUN_DIR"
echo ""

# Change to ridges directory and run the test
cd ../ridges

# Run the test and capture output
if [ -f "ridges.py" ]; then
    echo "Running: ./ridges.py test-agent --agent-file $AGENT_PATH --num-problems $NUM_PROBLEMS --problem-set $PROBLEM_SET --verbose"
    echo ""
    
    # Run the test with timeout
    timeout $TIMEOUT ./ridges.py test-agent --agent-file "$AGENT_PATH" --num-problems $NUM_PROBLEMS --problem-set "$PROBLEM_SET" --verbose 2>&1 | tee "../ridges-agent-workbench/$RUN_DIR/run.log"
    
    # Check if timeout occurred
    if [ $? -eq 124 ]; then
        echo "Test timed out after $TIMEOUT seconds" >> "../ridges-agent-workbench/$RUN_DIR/run.log"
    fi
else
    echo "Error: ridges.py not found in ../ridges directory" | tee "../ridges-agent-workbench/$RUN_DIR/run.log"
    echo "Please ensure the ridges repository is properly set up" >> "../ridges-agent-workbench/$RUN_DIR/run.log"
fi

# Return to workbench directory
cd ../ridges-agent-workbench

echo ""
echo "Test completed. Results saved to: $RUN_DIR"
echo "Log file: $RUN_DIR/run.log"
echo "Metadata: $RUN_DIR/meta.txt"
echo "Git info: $RUN_DIR/git_commit.txt"
