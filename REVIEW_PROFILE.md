# PR Review Rubric — JIRA Spec Artifacts

Derived from review patterns across 55 PRs (April 2025 – April 2026) in HL7/JIRA-Spec-Artifacts.

---

## Summary

This repo manages JIRA specification artifact XML files for HL7 FHIR IGs. PRs are almost always simple XML edits — adding new specs, bumping versions, or updating artifact lists. The review workload is light per PR, but a consistent set of checks applies every time. The patterns below are derived from actual review comments and decisions across the full year.

---

## Rubric: What to Check on Every PR

### 1. Version Deprecation — *Most Commonly Flagged Issue*

**The rule:** Any version you are no longer willing to maintain (i.e., you would not publish a technical correction against it) should be marked `deprecated="true"`. This specifically includes:

- **Ballot releases** once the corresponding official release is published. Never leave a ballot release un-deprecated after the official release ships.
- **Older official technical correction releases** once there is a new technical correction issued under the same minor release
- **Older official releases** when the WG confirms they would not produce a technical correction for them.
- **A ballot release should NOT be deprecated before its corresponding official release exists** — don't deprecate your only release.

**Diagnostic question to ask:** *"Will you potentially make a new release based on this version (e.g., a technical correction), or will all future fixes be in the next official release?"* If the answer is "no, all future work is in the next release," deprecate it.

**Common failure modes caught:**
- PR ships with a new official release but the ballot version that preceded it is still un-deprecated (PRs #1396, #1404, #1339, #1247, #1244, #1357, #1273, #1417, etc.)
- PR deprecates all prior releases preemptively, including the only active release (#1338 — rejected)
- Old official releases left active when a newer one is already out (#1347, #1279, #1249, #1239)

---

### 2. Default Version — Must Match the Latest Official Release

**The rule:** `defaultVersion` should point to the most recently published official release, never to a ballot or pre-release version if an official release exists.

**Common failure modes:**
- Ballot release is left as (or promoted to) `defaultVersion` (#1301, #1396)
- Default version not updated after a new official release is added (#1405, #1424)

---

### 3. Version Numbering Conventions

**FHIR HL7 versioning rules:**

| Situation | Correct version |
|---|---|
| First ballot | `1.0.0-ballot` |
| Second ballot (no 1.0.0 published yet) | `1.0.0-ballot2` |
| Official publish after ballot | `1.0.0` (drop the `-ballot` suffix — same base number) |
| Pre-publication snapshot | `1.0.0-snapshot` |
| CI build | no version suffix; reflected only in the `ciUrl` attribute |

**Key invariant:** You should not jump from `2.0.0-ballot` to publishing `2.1.0` without first publishing `2.0.0`. If a `2.0.0` was never published, the next ballot is `2.0.0-ballot2`. (#1300, #1301)

**Ballot version must use the correct HL7 season segment** in the URL (e.g., `2025Sep`, not just a year). (#1301, #1300)

---

### 4. Rename vs. Deprecate+Add — Frequent Source of Errors

**The rule:** If an artifact's `id`, `name`, or page title changed but it is still the *same artifact* conceptually, **keep the original `key`** and update the `id`/`name` in place. Do not deprecate the old entry and add a new one — that breaks JIRA artifact linkage.  This is detected by seeing both a deprecation and a new artifact with similar ids or names where it's likely the change could just be a new name or id.  If only one of the name or id have changed, it's very likely this is a rename.

**When to deprecate+add instead:** Only when the old artifact is genuinely gone and a truly new artifact (different concept, different key intent) has replaced it.

**Diagnostic question:** *"Is this a rename/refactor of the same thing, or did the old thing disappear and a new, distinct thing appear?"*

Caught in: #1457, #1466, #1432, #1342, #1272, #1251

---

### 5. CI Build URLs — Specific Format Required

**Rules:**
- Must be the root URL, no language path segments: ❌ `/en/index.html`, ❌ `/en/` — these are wrong
- No trailing slash: ❌ `https://build.fhir.org/ig/HL7/foo/`
- Correct pattern: `https://build.fhir.org/ig/HL7/[repo-name]`
- The `ciUrl` must be present; do not leave it blank
- If the `ciUrl` is absent a likely cause is that the committer did not declare the `ci-build` property in their publication-request.json file.  Inform the committer of that and point them at https://confluence.hl7.org/spaces/FHIR/pages/144970227/IG+Publication+Request+Documentation for guidance.

Caught in: #1436, #1400, #1374, #1429

---

### 6. New Spec Files — Completeness Check

When a brand-new spec XML file is added:

- [ ] The new XML file must also have a corresponding entry in `SPECS-FHIR.xml` (#1469)
- [ ] The file must be named `[family-name]-[spec-name].xml` — **including the `.xml` extension** (#1469)
- [ ] `gitUrl` attribute is required and must begin with `https://github.com/HL7/` (#1374)
- [ ] The `ciUrl` must be populated, even in the initial commit (#1374)
- [ ] The current version URL must be filled in (should match the ci-build URL initially) (#1374)

---

### 7. Do Not Commit the Workgroups File

The shared `workgroups` file, or any other file that is not an update to a SPECS file or a specification file should never appear in a PR that is modifying a specific IG's spec. If it shows up in the diff, it must be removed before merge. (#1432)

---

## Approval Patterns

### Typically approves quickly when:
- A ballot release is correctly deprecated after the official release ships
- Version numbers follow FHIR conventions
- CI URL is the clean root
- `defaultVersion` is updated to the new official release
- Renames are done by updating the key in place
- A comment addresses an issue in a clarifying question (see below) and indicates that the committed content is correct

### Consistently blocks (CHANGES_REQUESTED) when:
- A ballot or snapshot release is left un-deprecated after the official release (#1396, #1404, #1417, #1357, etc.)
- A ballot is set as the default version when there's an official release (#1301)
- A rename is clearly implemented as deprecate-old + add-new (#1457, #1272)
- CI URL has a language segment or trailing slash (#1400, #1436)
- New spec is missing its SPECS-FHIR.xml entry (#1469)
- Wrong HL7 ballot season in URL for a ballot release (#1301)

### Asks clarifying questions before deciding when:
- An older version is not deprecated and it is unclear whether that older version could receive technical corrections (deprecation intent)
- The version numbering sequence has gaps (e.g., no 1.0.0 between a ballot and a 2.x release)
- Deprecations in the diff might actually be renames
- The rationale for keeping multiple versions active is unclear

---

## Suggested Review Approach

- Any response should not comment on what was done right.  Only raise questions or identify issues (if there are any)
- Ask questions rather than issuing directives when intent is ambiguous: *"To confirm, you don't want to deprecate X and would consider a technical correction against it?"*
- When explaining deprecation, frame it in terms of feedback channels: *"If you wouldn't publish a technical correction against 1.0.0, you should deprecate it so people don't submit change requests against it."*
- Provide the correct value when known: *"The ballot URL should be 2025Sep"* — not just *"the ballot URL is wrong."*
- CHANGES_REQUESTED is appropriate even for small fixes expected in a follow-up commit; re-review and approve once addressed. Rejected PRs generally lead to a new PR rather than reopening the closed one.

---

## Quick Pre-Submission Checklist

Before opening a PR against this repo, verify:

- [ ] All ballot versions preceding a new official release are marked `deprecated="true"`
- [ ] Older official releases are either deprecated or explicitly intended to receive further maintenance
- [ ] `defaultVersion` points to the latest official release (not a ballot)
- [ ] Version number follows FHIR convention — no skipping intermediate versions
- [ ] CI URL is the bare root path with no language segments or trailing slash
- [ ] If this is a new spec: SPECS-FHIR.xml entry added, file named correctly, gitUrl present
- [ ] No workgroups file in the diff
- [ ] Artifact changes that look like deprecate+add are actually renames → update in place instead
