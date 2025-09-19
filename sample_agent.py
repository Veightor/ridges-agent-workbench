"""
Sample Ridges Agent for Testing
This is a simple agent that can be used for testing the workbench.
"""

def agent_main(input_dict):
    """
    Main agent function that processes input and returns a patch.
    
    Args:
        input_dict (dict): Input containing problem information
        
    Returns:
        dict: Dictionary with "patch" key containing the solution
    """
    
    # Extract problem information
    problem_description = input_dict.get('problem', '')
    problem_type = input_dict.get('type', 'unknown')
    
    # Simple example: return a basic patch
    # In a real agent, this would contain actual problem-solving logic
    patch = f"""
# Sample patch for {problem_type} problem
# Problem: {problem_description[:100]}...

# This is where the actual solution would go
# For testing purposes, we're just returning a placeholder

def solution():
    # Add your solution logic here
    pass

# Example fix
- old_code
+ new_code
"""
    
    return {
        "patch": patch.strip()
    }

# Test the agent function
if __name__ == "__main__":
    # Test with sample input
    test_input = {
        "problem": "Fix the bug in the following code",
        "type": "bug_fix",
        "code": "def broken_function():\n    return None"
    }
    
    result = agent_main(test_input)
    print("Agent test successful!")
    print("Patch preview:")
    print(result["patch"][:200] + "...")
