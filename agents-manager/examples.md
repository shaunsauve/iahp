# Agent Workflow Examples

Common patterns for spawning and coordinating agents using the agents-manager skill.

## When to Use Agents vs Direct Skills

### Use Agents When:
- **Parallel execution needed** — Multiple independent tasks running simultaneously
- **Background processing** — Long-running tasks that shouldn't block main thread
- **Complex coordination** — Multi-step workflows with agent handoffs
- **Task tool available** — Your LLM supports Task tool (Claude Code CLI)

### Use Direct Skills When:
- **Sequential workflow** — One task at a time, step-by-step
- **No Task tool** — LLM doesn't support subagent spawning (Gemini, older models)
- **Simpler setup** — Prefer straightforward single-context execution
- **Tight integration** — Want all work in current conversation context

### Fallback Pattern (No Task Tool)

**IMPORTANT:** If Task tool is not available, do NOT automatically invoke skills as a fallback without explicit user confirmation.

**Why:** Direct skill invocation loads skill content into current context, which consumes tokens and can pollute the working context. This should be a deliberate choice, not an automatic fallback.

**Correct approach when agents unavailable:**
1. Inform user: "Task tool not available - cannot spawn agents"
2. Warn: "Direct skill invocation will load skill into current context (token cost)"
3. Ask: "Would you like me to invoke /[skill] directly instead?"
4. Wait for confirmation before loading skill

**Key difference:**
- **Agents** — Separate subagent contexts, isolated execution, parallel capable
- **Direct skills** — Loads into current context, sequential only, permanent token cost

---

## Basic Agent Spawning

### Single Agent Task

**Scenario:** Implement a feature

```
spawn coder "Add user authentication with JWT tokens"
```

The agents-manager will:
1. Read agents.json to find coder configuration
2. Read coder SKILL.md (and baseline)
3. Spawn Task with subagent_type="general-purpose"
4. Return agent ID for tracking

### Quick Exploration

**Scenario:** Find where errors are handled

```
spawn explorer "Find all error handling code in the API layer"
```

Uses Explore subagent type with haiku model for fast, cost-efficient exploration.

## Multi-Agent Workflows

### Sequential Handoff

**Pattern:** Each agent completes before the next starts

```
1. spawn architect "Design authentication system"
   [wait for completion, review output]

2. spawn coder "Implement authentication based on architecture"
   [wait for completion]

3. spawn tester "Create test suite for authentication"
   [wait for completion]

4. spawn reviewer "Review authentication implementation and tests"
```

**Use when:** Each phase depends on previous phase output

### Parallel Execution

**Pattern:** Multiple independent agents work simultaneously

```
spawn coder "Implement frontend authentication UI"
spawn coder "Implement backend authentication API"
spawn coder "Add authentication database migrations"
```

All spawned in single message using multiple Task calls.

**Use when:** Tasks are independent and can be done concurrently

### Collaborative Deep Dive

**Pattern:** Primary agent delegates to specialists

```
1. spawn architect "Plan microservices refactor"

   Architect identifies need to:
   - Understand current service boundaries
   - Review API contracts
   - Analyze database dependencies

2. Architect spawns supporting agents:
   - spawn explorer "Map current service call patterns"
   - spawn explorer "Analyze database relationships"
   - spawn reviewer "Review existing API contracts"

3. Architect synthesizes findings and creates plan
```

**Use when:** Complex task requires exploration before design

## Agent Lifecycle Management

### Resume Agent Session

**Scenario:** Continue work on paused agent

```
# Initial spawn returns agent ID
spawn coder "Implement user profile CRUD operations"
> Agent ID: task_abc123

# Later, resume the agent
resume task_abc123
```

Agent continues with full previous context preserved.

### Monitor Background Agent

**Scenario:** Long-running agent, check progress

```
# Spawn as background task
spawn coder "Refactor entire authentication system" --background

# Check output periodically
output task_abc123 --non-blocking

# Fetch final results when complete
output task_abc123
```

### Stop Agent

**Scenario:** Agent no longer needed or going wrong direction

```
stop task_abc123
```

## Advanced Coordination Patterns

### Test-Driven Development Flow

```
1. spawn architect "Design feature architecture"
2. spawn tester "Write test specifications based on architecture"
3. spawn coder "Implement feature to pass tests"
4. spawn reviewer "Validate implementation and test coverage"
```

Tests guide implementation; reviewer ensures quality.

### Iterative Refinement

```
1. spawn coder "Initial implementation of search feature"
2. spawn reviewer "Review search implementation"
3. Based on reviewer feedback:
   resume task_coder "Address reviewer concerns"
4. spawn tester "Add edge case tests"
```

Agents collaborate iteratively until quality standards met.

### Exploration → Design → Implementation

```
1. spawn explorer "Understand current authentication system"
   [Returns: authentication handled in auth.service.ts, uses JWT]

2. spawn architect "Design OAuth integration for existing JWT system"
   [Returns: architecture plan with migration strategy]

3. spawn coder "Implement OAuth based on architecture plan"
   [Uses architecture plan as context]
```

Systematic approach: understand → plan → execute

### Multi-Repository Coordination

```
# Frontend repo
spawn coder "Add authentication UI components"

# Backend repo (different working directory)
spawn coder "Add authentication API endpoints" --cwd=/path/to/backend

# Shared library repo
spawn coder "Add authentication types and interfaces" --cwd=/path/to/shared
```

Coordinate work across multiple codebases.

## Model Selection Strategies

### Cost Optimization

```
# Use haiku for exploration (fast & cheap)
spawn explorer "Find authentication code" --model=haiku

# Use sonnet for implementation (balanced)
spawn coder "Implement OAuth flow" --model=sonnet

# Use opus for complex architecture (high quality)
spawn architect "Design distributed auth system" --model=opus
```

### Speed vs Quality Tradeoff

**Fast iteration:**
- explorer (haiku): Quick scans
- coder (haiku): Simple refactors, obvious fixes

**Balanced:**
- coder (sonnet): Feature implementation
- reviewer (sonnet): Code review

**Complex work:**
- architect (opus): System design
- coder (opus): Complex algorithms

## Error Handling

### Agent Fails to Complete

```
spawn coder "Implement feature X"
> Agent encountered error: Missing dependency Y

# Address the issue
spawn coder "Install dependency Y"

# Retry original task
spawn coder "Implement feature X"
```

### Ambiguous Task

```
spawn coder "Make it better"
> Agent requests clarification: What aspect should be improved?

# Provide clearer task
spawn coder "Improve API response time by adding caching"
```

## Tracking Multiple Agents

### List All Active Agents

```
list
```

Shows:
- Agent ID
- Type (coder, architect, etc.)
- Status (running, completed, failed)
- Task description
- Start time

### Bulk Operations

```
# Check all outputs
output --all

# Stop all agents
stop --all
```

## Best Practices

1. **Clear task descriptions** — Be specific about what the agent should do
2. **Use appropriate models** — Haiku for quick tasks, Sonnet for most work, Opus for complex design
3. **Monitor long-running agents** — Check progress on background tasks
4. **Coordinate handoffs** — Ensure agents have context from previous agents' work
5. **Track agent IDs** — Keep record for resume/output operations
6. **Parallel when possible** — Spawn independent agents together for speed
7. **Sequential when dependent** — Wait for agent output when next agent needs it
8. **Choose right agent type** — Explore for discovery, Plan for architecture, general-purpose for implementation

