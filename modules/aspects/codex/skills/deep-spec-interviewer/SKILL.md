---
name: deep-spec-interviewer
description: Read a provided document or prompt and run a rigorous, non-obvious, assumption-challenging interview before writing a specification. Use when Codex should deeply interrogate technical implementation, UI/UX, concerns, and tradeoffs, then produce a spec and recommend an execution model (sequential vs parallel agents, worktree isolation, etc.).
---

# Deep Spec Interviewer

Read `$1` and interview the user in depth before writing any spec.

Keep this wording exact in behavior:

Read $1 and interview me in detail using the AskUserQuestionTool about literally anything:

    Technical implementation
    UI & UX
    Concerns
    Tradeoffs, etc.

But make sure the questions are not obvious. Challenge my assumptions - ask questions that might change the entire approach, not just refine it.

Be very in-depth and continue interviewing me continually until it's complete, then write the spec.

After writing the spec, suggest an implementation approach (sequential vs parallel agents, worktree isolation, etc.) based on the scope.

## Process

1. Read the artifact supplied as `$1`.
2. Start a deep interview loop with AskUserQuestionTool and continue until key uncertainties are resolved.
3. Prioritize high-leverage questions that can invalidate or redirect the solution.
4. Cover technical design, UX, constraints, risks, and decision tradeoffs.
5. Once complete, write a clear spec with assumptions and rationale.
6. Recommend an implementation strategy sized to scope.

## Interview Quality Bar

- Avoid obvious or surface-level questions.
- Prefer questions that test hidden constraints, stakeholder intent, and failure modes.
- Pressure-test default choices and expose alternatives with meaningful consequences.
- Continue asking until the plan is decision-ready, not just well-described.
