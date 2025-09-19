@echo off
REM Ridges Agent Test Runner (Windows Batch)
REM Usage: run_agent_test.bat [agent_path] [num_problems] [problem_set] [timeout]

REM Default values
set AGENT_PATH=..\ridges\miner\top_agent_tmp.py
set NUM_PROBLEMS=1
set PROBLEM_SET=easy
set TIMEOUT=300

REM Parse command line arguments
if not "%~1"=="" set AGENT_PATH=%~1
if not "%~2"=="" set NUM_PROBLEMS=%~2
if not "%~3"=="" set PROBLEM_SET=%~3
if not "%~4"=="" set TIMEOUT=%~4

REM Create timestamp for this run
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "TIMESTAMP=%dt:~0,8%_%dt:~8,6%"
set "RUN_DIR=runs\%TIMESTAMP%"

REM Create run directory
if not exist "%RUN_DIR%" mkdir "%RUN_DIR%"

REM Save metadata
echo Agent Path: %AGENT_PATH% > "%RUN_DIR%\meta.txt"
echo Number of Problems: %NUM_PROBLEMS% >> "%RUN_DIR%\meta.txt"
echo Problem Set: %PROBLEM_SET% >> "%RUN_DIR%\meta.txt"
echo Timeout: %TIMEOUT% seconds >> "%RUN_DIR%\meta.txt"
echo Timestamp: %TIMESTAMP% >> "%RUN_DIR%\meta.txt"

REM Save git commit info from ridges repo
if exist "..\ridges" (
    cd ..\ridges
    git log -1 --format="%%H %%s" > "..\ridges-agent-workbench\%RUN_DIR%\git_commit.txt"
    cd ..\ridges-agent-workbench
) else (
    echo Ridges repo not found > "%RUN_DIR%\git_commit.txt"
)

REM Run the test
echo Starting Ridges agent test...
echo Agent: %AGENT_PATH%
echo Problems: %NUM_PROBLEMS% (%PROBLEM_SET%)
echo Timeout: %TIMEOUT% seconds
echo Run directory: %RUN_DIR%
echo.

REM Change to ridges directory and run the test
cd ..\ridges

REM Run the test and capture output
if exist "ridges.py" (
    echo Running: .\ridges.py test-agent --agent-file %AGENT_PATH% --num-problems %NUM_PROBLEMS% --problem-set %PROBLEM_SET% --verbose
    echo.
    
    REM Run the test (Windows doesn't have timeout command, so we'll run without it)
    .\ridges.py test-agent --agent-file "%AGENT_PATH%" --num-problems %NUM_PROBLEMS% --problem-set "%PROBLEM_SET%" --verbose > "..\ridges-agent-workbench\%RUN_DIR%\run.log" 2>&1
) else (
    echo Error: ridges.py not found in ..\ridges directory > "..\ridges-agent-workbench\%RUN_DIR%\run.log"
    echo Please ensure the ridges repository is properly set up >> "..\ridges-agent-workbench\%RUN_DIR%\run.log"
)

REM Return to workbench directory
cd ..\ridges-agent-workbench

echo.
echo Test completed. Results saved to: %RUN_DIR%
echo Log file: %RUN_DIR%\run.log
echo Metadata: %RUN_DIR%\meta.txt
echo Git info: %RUN_DIR%\git_commit.txt
