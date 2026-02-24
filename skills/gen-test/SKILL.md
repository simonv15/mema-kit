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
