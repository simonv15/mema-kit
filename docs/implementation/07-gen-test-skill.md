# 07 — Gen-Test Skill

**Produces:** `skills/gen-test/SKILL.md`
**Milestone:** 4
**Dependencies:** 06-plan-docs-skill (reads plan.md as primary input)

---

## What This Skill Does

`/gen-test` generates test cases following TDD — tests are written **before** the implementation code exists. The agent reads the plan, understands what needs to be built, and writes tests that define the expected behavior. These tests are designed to **fail** initially (because the code doesn't exist yet) and pass after `/implement` runs.

Tests are written to the **codebase** (e.g., `src/tests/`), not to `.praxis/`. They're real test files that run with the project's test framework.

Example usage:
```
/gen-test generate tests for the task CRUD endpoints
/gen-test write tests for the auth middleware
/gen-test create tests for the data validation layer
```

---

## Key Design Decisions

### 1. Tests live in the codebase, not in memory

**Decision: Write test files directly to the project's source tree, not to `.praxis/`.**

Reasoning:
- Tests are code. They belong with the codebase, committed to git, run by CI/CD.
- `.praxis/` is for agent memory (decisions, context, plans). Putting test code there would blur the line between "knowledge about the project" and "the project itself."
- Test files in the codebase are immediately runnable. The developer can do `npm test` and see them fail (TDD red phase) without any extra steps.
- This also means `/gen-test` is the first skill that writes to the codebase (outside `.praxis/`). All prior skills only write memory files.

### 2. Detect the project's testing framework, don't assume one

**Decision: The agent detects the existing test framework from the project's configuration before writing tests.**

Reasoning:
- Different projects use different test frameworks: Jest, Vitest, Mocha, pytest, Go's testing package, etc.
- Assuming a framework (e.g., always writing Jest tests) would produce unusable tests in projects using different frameworks.
- Detection strategy (in priority order):
  1. Check `package.json` for test-related dependencies (jest, vitest, mocha, @testing-library)
  2. Check for test config files (`jest.config.*`, `vitest.config.*`, `pytest.ini`, `.mocharc.*`)
  3. Check for existing test files to see patterns and conventions
  4. Check `CLAUDE.md` for testing instructions
  5. If nothing is found, ask the user what framework to use

### 3. Follow existing test conventions

**Decision: Match the project's existing test file patterns — naming, location, import style, assertion library.**

Reasoning:
- Test consistency matters. If existing tests use `describe/it` blocks with `expect`, the new tests should too. If they use `test()` instead of `it()`, match that.
- If existing tests live in `src/__tests__/`, new tests go there too. If they're co-located (`foo.test.ts` next to `foo.ts`), match that pattern.
- The agent should read 1-2 existing test files before writing new ones, purely to learn conventions. If no test files exist, use the framework's documented default patterns.
- Conventions to detect:
  - File naming: `*.test.ts` vs `*.spec.ts` vs `test_*.py`
  - Directory structure: `__tests__/` vs `tests/` vs co-located
  - Import style: `import { expect } from 'vitest'` vs global `expect`
  - Assertion style: `expect().toBe()` vs `assert.equal()`
  - Setup/teardown patterns: `beforeEach` vs `setUp`

### 4. What to test: behavior, not implementation

**Decision: Generate tests that verify behavior (inputs → outputs) rather than testing internal implementation details.**

Reasoning:
- Implementation-detail tests break when code is refactored, even if behavior is unchanged. "Test that function calls database.query()" is fragile. "Test that creating a task returns a 201 with the task ID" is stable.
- Behavior tests serve as living documentation. Reading the tests tells you what the system does, not how it does it internally.
- The plan's general section describes behavior (what the feature does). The detailed section describes implementation (how to build it). Tests should derive from the general section.
- Exception: tests for pure utility functions can test internal logic directly, since those functions ARE their interface.

### 5. Test scope: unit tests + critical-path integration tests

**Decision: Generate unit tests for core logic and integration tests for critical paths only.**

Reasoning:
- Unit tests are fast, reliable, and cover edge cases well. They should cover the core business logic of each plan step.
- Integration tests verify that components work together (API endpoint → handler → database). They're slower and more brittle, but essential for critical paths (happy path, auth, error handling).
- Exhaustive integration tests would be too slow to run during TDD cycles and too complex to generate accurately before implementation.
- The split: unit tests for every function/module in the plan, integration tests for 2-3 critical user journeys.

### 6. No memory writes

**Decision: `/gen-test` does NOT write to `.praxis/` memory.**

Reasoning:
- Tests are artifacts (code), not knowledge (memory). The plan is already in memory. The tests are in the codebase.
- Writing "I generated 15 tests for user-crud" to memory provides no future value — the test files themselves are the record.
- Keeping `/gen-test` memory-free simplifies the skill and makes it faster.
- The only index update: if the task status should note "tests generated," that update happens in `status.md` as a note, not as a new memory file.

Exception: If generating tests reveals a **plan issue** (e.g., the plan describes an endpoint but the test shows it's ambiguous), the agent should update the plan, which IS a memory write. But this is a plan correction, not a gen-test memory operation.

---

## Implementation Guide

### Step 1: Create the SKILL.md file structure

```
skills/
└── gen-test/
    └── SKILL.md
```

### Step 2: Write the SKILL.md

The skill has a unique structure compared to other skills:
1. **LOAD** — read the plan (and optionally existing tests)
2. **DETECT** — find the testing framework and conventions
3. **GENERATE** — write test files to the codebase
4. **VERIFY** — run tests to confirm they fail correctly (TDD red phase)

Note: No AUTO-SAVE or AUTO-INDEX phases (since this skill doesn't write to memory).

### Step 3: Test framework detection

Test on different project types:
- A Node.js project with Jest → should generate Jest tests
- A Python project with pytest → should generate pytest tests
- A project with no test framework → should ask the user

### Step 4: Test TDD flow

Run `/plan-docs` → `/gen-test` → verify tests exist and fail → `/implement` → verify tests pass.

---

## Full SKILL.md Content

```markdown
---
description: Generate TDD test cases from an implementation plan. Tests are written first (red phase) — they should fail until /implement makes them pass.
---

# /gen-test — TDD Test Generation

You are generating test cases for a development task using Test-Driven Development. Tests should define the expected behavior BEFORE implementation code exists. They should fail now and pass after /implement runs.

## Phase 1: LOAD (Read the Plan)

1. **Check prerequisites:** If `.praxis/` doesn't exist, stop and tell the user: "No .praxis/ directory found. Run /kickoff first to initialize the project."

2. **Read the index:** Read `.praxis/index.md`.

3. **Find the plan:** Based on the user's request, identify the task and read `.praxis/task-memory/<task-name>/plan.md`.
   - If no plan exists, tell the user: "No plan found for [task]. I can generate tests from your description, or you can run /plan-docs first to create a plan. What would you prefer?"
   - If the user chooses to proceed without a plan, ask them to describe what they want to test.

4. **Load supporting context:** Read any related decision files or architecture docs that affect the tests (e.g., auth decisions affect how tests should handle authentication).

## Phase 2: DETECT (Find Testing Conventions)

Before writing any tests, understand the project's testing setup:

1. **Detect test framework:**
   - Check `package.json` (or equivalent) for test dependencies: jest, vitest, mocha, @testing-library, pytest, etc.
   - Check for test config files: `jest.config.*`, `vitest.config.*`, `pytest.ini`, `setup.cfg`, `.mocharc.*`
   - Check CLAUDE.md for testing instructions
   - If no framework is detected, ask the user: "I don't see a test framework configured. What should I use? (e.g., Jest, Vitest, pytest)"

2. **Detect test conventions:**
   - Find existing test files (look for `*.test.*`, `*.spec.*`, `test_*.*` patterns)
   - Read 1-2 existing test files to learn:
     - File naming convention (`*.test.ts` vs `*.spec.ts`)
     - Directory structure (`__tests__/` vs `tests/` vs co-located)
     - Import style and assertion patterns
     - Setup/teardown patterns
     - Any custom test utilities or helpers
   - If no existing tests exist, use the framework's standard conventions

3. **Report to the user:** "I'll generate [framework] tests following your existing conventions: [describe detected patterns]."

## Phase 3: GENERATE (Write Test Files)

Generate test files based on the plan. Follow these principles:

### Test design principles:

1. **Test behavior, not implementation.** Each test should verify an observable outcome:
   - "Creating a task with valid data returns 201 and the task ID" ✓
   - "Creating a task calls insertTask on the repository" ✗ (implementation detail)

2. **One concept per test.** Each `it()` / `test()` block verifies one behavior. Don't test multiple behaviors in a single test.

3. **Descriptive names that read like sentences:**
   - `it('returns 404 when task does not exist')` ✓
   - `it('test get task error')` ✗

4. **Cover the key paths for each plan step:**
   - **Happy path** — normal, expected input produces correct output
   - **Validation** — invalid input is rejected with appropriate errors
   - **Edge cases** — empty input, boundary values, missing optional fields
   - **Error cases** — what happens when dependencies fail (database error, network timeout)

### What to generate:

**Unit tests** for each major function or module in the plan:
- Test core business logic (data transformations, validation rules, calculations)
- Test with various inputs: valid, invalid, edge cases
- Mock external dependencies (database, APIs, file system)

**Integration tests** for critical paths (2-3 tests):
- Test the full request → response flow for the most important endpoints/features
- Test authentication/authorization if applicable
- Test error handling for the most likely failure modes

### File structure:

- Create test files matching the project's detected conventions
- If tests are co-located: create `foo.test.ts` next to `foo.ts`
- If tests are in a directory: create files in `__tests__/` or `tests/` matching the project structure
- Group related tests in `describe` blocks (or equivalent)

### Test scaffolding:

For each test file, include:
- All necessary imports (test framework, the module under test, mocks)
- Setup and teardown hooks if needed
- Clearly commented sections for each plan step being tested
- Placeholder implementations that will fail:
  - For modules that don't exist yet: import them anyway (the import will fail until /implement creates them)
  - For API tests: write the expected request/response even though the endpoint doesn't exist

## Phase 4: VERIFY (Confirm Tests Fail Correctly)

After generating all test files:

1. **Run the test suite** using the project's test command (from `package.json` scripts, Makefile, or detected framework CLI)

2. **Verify correct failures:**
   - Tests should fail because the implementation doesn't exist yet (import errors, module not found, endpoint 404)
   - Tests should NOT fail because of test syntax errors, wrong imports, or framework misconfiguration
   - If tests fail for the wrong reasons (test code bugs), fix the test code immediately

3. **Report to the user:**

```
Test generation complete!

Created [N] test files:
- [file path] — [what it tests] ([N] tests)
- [file path] — [what it tests] ([N] tests)

Test results: [N] tests, [N] failing (expected — implementation doesn't exist yet)

These tests define the expected behavior for [task name].
Run /implement to make them pass.
```

## Notes

- If generating tests reveals ambiguity in the plan (e.g., "what should happen when X?"), update the plan file to clarify, then generate tests for the clarified behavior.
- If the project has no test runner configured and the user wants one, help them set it up before generating tests.
- Update `.praxis/task-memory/<task-name>/status.md` to note that tests have been generated.
```

---

## Design Notes

### Why tests import modules that don't exist yet

This is the TDD contract. Writing `import { createTask } from '../services/task.service'` in a test, when `task.service.ts` doesn't exist yet, creates a clear implementation target. The developer (or `/implement`) knows exactly what to create and what interface it should have.

The test file becomes a **specification document** — it defines the public interface before the implementation exists.

### Why integration tests are limited to 2-3

Integration tests are expensive:
- They take longer to write (more setup, more mock infrastructure)
- They take longer to run (real or simulated I/O)
- They're more likely to be wrong before implementation exists (because they depend on details that might change during coding)

Unit tests are cheap and stable. They test isolated logic that maps directly from the plan. We generate many unit tests and few integration tests to maximize coverage with minimal brittleness.

### Why this skill doesn't modify memory

Every other skill (except `/profile`) writes to `.praxis/`. Why not `/gen-test`?

Because test files ARE the output. In `/explore`, the output is knowledge (goes to memory). In `/plan-docs`, the output is a plan (goes to memory). In `/gen-test`, the output is code (goes to the codebase). The test files serve as their own record.

Adding a memory entry like "generated 15 tests for user-crud" provides no actionable information for future sessions. The test files themselves are discoverable, runnable, and self-documenting.

The one exception: if test generation reveals a plan issue, the plan is updated. This is a correction to an existing memory file, not a new memory operation.

### Handling projects without existing tests

When a project has no tests at all (no framework, no test files), the agent should:
1. Ask the user which framework they prefer
2. Help set up the minimal test configuration (install the package, create config file)
3. Then generate tests

This test-setup step is a one-time cost that makes all future `/gen-test` runs smooth. The agent should not skip it and write tests that can't run.
