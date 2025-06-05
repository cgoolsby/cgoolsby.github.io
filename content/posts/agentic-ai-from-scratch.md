+++
title = "Building Your First AI Agent from Scratch: A Practical Guide"
description = ""
date = 2025-05-11
author = {name = "Curtis Goolsby", email = "curtis@kubepros.dev"}
tags = []
draft = false
+++


Ever wondered how AI agents like ChatGPT's Code Interpreter or AutoGPT actually work under the hood? Today, we'll demystify AI agents by building one from scratch using just Python and a local LLM. No cloud services, no complex frameworks - just the core concepts that power modern AI agents.

## What Are AI Agents?

At its core, an "agentic AI" is simply an LLM (Large Language Model) that has been given **agency** - the ability to take actions in the world rather than just generate text. 

Think of it this way:
- **LLM alone**: Can only think and respond with text
- **LLM with agency**: Can think AND act to achieve goals

AI agents are programs that give LLMs this agency through tools. Unlike traditional chatbots that just respond to queries, agents can:
- Break down complex tasks into steps
- Execute actions in the real world
- Learn from results and adjust their approach
- Work toward specific goals

The key insight is that we can give LLMs the ability to use "tools" - functions they can call to interact with the world. This transforms them from passive responders into active agents with agency.

## Our Project: A Filesystem Navigator

We'll build an agent that can navigate your filesystem to find files. It's simple enough to understand but demonstrates all the core concepts:
- **Perception**: The agent can "see" directory contents with `ls`
- **Action**: It can navigate with `cd`
- **Reasoning**: It decides where to look next
- **Goal**: Find a specific file

## The Architecture

Here's how our agent works:

```
┌─────────────────┐
│   User Goal     │ "Find backup.sh"
└────────┬────────┘
         │
┌────────▼────────┐
│   Agent Loop    │ 
│                 │ ◄─────┐
│ 1. Observe      │       │
│ 2. Think        │       │
│ 3. Act          │       │
│ 4. Check goal   │       │
└────────┬────────┘       │
         │                │
┌────────▼────────┐       │
│      LLM        │       │
│  (Reasoning)    │       │
└────────┬────────┘       │
         │                │
┌────────▼────────┐       │
│ Action Executor │       │
│   - ls          │       │
│   - cd          │       │
│   - done        │       │
└─────────────────┘───────┘
```

## Key Components

### 1. Structured Output

The magic happens when we force the LLM to respond in JSON format. This transforms free-form text into actionable commands:

```python
def create_prompt(self) -> str:
    return f"""You are a filesystem navigation agent. Your task is to find the file: '{self.target_file}'

Current directory: {self.current_dir}
Last ls output: {self.last_ls_output}

You must respond ONLY with valid JSON in this exact format:
{{
    "thought": "your reasoning about what to do next",
    "action": "action_name",
    "args": {{}}
}}
"""
```

### 2. Action Execution

Each JSON response triggers real actions:

```python
def execute_action(self, action: str, args: Dict[str, Any]) -> str:
    if action == "ls":
        files = list(self.current_dir.iterdir())
        self.last_ls_output = [f.name for f in files]
        return f"Contents: {', '.join(self.last_ls_output)}"
        
    elif action == "cd":
        path = args.get("path", "")
        new_path = self.current_dir / path
        if new_path.exists() and new_path.is_dir():
            self.current_dir = new_path
            return f"Changed to: {self.current_dir}"
```

### 3. The Agent Loop

The heart of any agent is its loop - observe, think, act, repeat:

```python
def find_file(self, target_file: str, max_steps: int = 20) -> bool:
    for step in range(max_steps):
        # Get LLM decision
        prompt = self.create_prompt()
        response = self.query_llm(prompt)
        
        # Execute action
        action = response.get("action")
        args = response.get("args", {})
        result = self.execute_action(action, args)
        
        # Check if done
        if action == "done":
            return True
```

## Running the Agent

Let's see it in action:

```bash
$ ./setup.sh  # Creates test filesystem
$ python filesystem_agent.py backup.sh

🔍 Starting search for: backup.sh
📂 Starting directory: /Users/you/test_environment

Step 1:
💭 Thought: I need to see what's in this directory
🎯 Action: ls
📋 Result: Contents: documents, downloads, projects, photos, music...

Step 2:
💭 Thought: backup.sh sounds like a script, let me check projects
🎯 Action: cd
📋 Result: Changed to: /Users/you/test_environment/projects

Step 3:
💭 Thought: Let me look inside the projects directory
🎯 Action: ls
📋 Result: Contents: web, mobile, scripts, data

Step 4:
💭 Thought: Scripts folder likely contains .sh files
🎯 Action: cd
📋 Result: Changed to: /Users/you/test_environment/projects/scripts

Step 5:
💭 Thought: Let me check what's in scripts
🎯 Action: ls
📋 Result: Contents: backup.sh, deploy.py, analyze_data.r

Step 6:
💭 Thought: Found it! backup.sh is here
🎯 Action: done
📋 Result: Task completed!

✅ Success! Found backup.sh at /Users/you/test_environment/projects/scripts
```

## Why This Matters

This simple example demonstrates the fundamental pattern behind all AI agents:

1. **Tool Use**: LLMs can't directly interact with the world, but they can generate structured commands for tools that can
2. **State Management**: Agents maintain context between actions (current directory, previous results)
3. **Goal-Directed Behavior**: The agent works autonomously toward a specific objective
4. **Reasoning Loop**: Each action is based on observations and reasoning

## Extending the Concept

This pattern scales to complex agents:
- **Web Agents**: Replace `ls/cd` with `click/type/navigate`
- **Code Agents**: Add `read_file/write_file/run_tests`
- **Research Agents**: Add `search/summarize/extract`
- **Data Agents**: Add `query/transform/visualize`

The core loop remains the same - observe, think, act, repeat.

## Key Takeaways

1. **Agents = LLM + Tools + Loop**: That's really all there is to it
2. **Structured Output is Critical**: JSON/XML/etc. bridges natural language to code
3. **State Management Matters**: Agents need memory between actions
4. **Safety is Important**: Always validate and sandbox agent actions

## Try It Yourself

The complete code is available on [GitHub](https://github.com/cgoolsby/agentic-ai-from-scratch). Some experiments to try:
- Add more tools (mkdir, rm, grep)
- Implement memory of visited directories
- Add parallel search capabilities
- Create a web navigation agent using the same pattern

Building AI agents isn't magic - it's just giving LLMs agency through tools. An "agentic AI" is nothing more than an LLM with the ability to act. Start simple, understand the fundamentals, and you'll be building sophisticated agents in no time.

---

