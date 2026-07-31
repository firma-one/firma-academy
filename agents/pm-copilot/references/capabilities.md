# PM Copilot — Internal Capabilities (NOT skills)

These are the shared publishing/notification mechanics the **specialization skills**
use internally. They are deliberately NOT exposed as top-level skills — PM Copilot is a
delivery advisor, not a utility agent. A skill cites the relevant capability here rather
than re-describing the mechanics (single source of truth; no drift).

Governing principle: the further an action reaches toward external stakeholders, the more
it defaults to human review. Confluence/Drive (internal) → direct write. Gmail/Slack
(reach people) → draft first.

## publish-to-Confluence (team system of record)
Publish team artefacts (Fortnightly Dashboard, Governance Intelligence) as Confluence pages
in space **Atlas** (key `AT`, spaceId `458756`). Everything lives under the **Project Atlas — Governance**
tree (pageId **524289**) — NEVER at the space root.
- Tool: `createConfluencePage` (new) / `updateConfluencePage` (revise or re-parent). ALWAYS set `parentId`
  when creating — a page created without a parent lands orphaned at the space root (the bug this rule fixes).
- **Where each report goes (parent pages under Project Atlas — Governance, pageId 524289):**
  - **Sprint reports** (Fortnightly Dashboard, Governance Intelligence) → under **"9. Sprint Reports"**,
    pageId **1802252**. One dated child page per sprint, e.g. "Fortnightly Dashboard — S12",
    "Governance Intelligence — S12" (`parentId: 1802252`).
  - Related lifecycle pages already in the tree, for reference/linking: 1. Project Charter (65928),
    2. Architecture Decision Records (524310), 3. RAID Log (557057), 4. Meeting Notes (589826 — sprint/steering
    minutes nest here), 5. Agile Operating Principles (1441793), 6. Team Leave Calendar (1474561),
    7. Functional Requirements/PRD (1507329), 8. Glossary (1540097).
  - **Meeting Notes convention (under 4. Meeting Notes, 589826):** children are titled `YYYY-MM-DD · <Meeting Name>`
    (date-prefixed → chronological sort; NOT numbered 4.x). Sprint reviews/retrospectives are NOT meeting-note
    pages — their substance is the Sprint Report (Fortnightly Dashboard under 9. Sprint Reports, 1802252). Any
    new meeting-note page follows the dated title and nests under 589826.
- Layout: a **new dated page per sprint** under the correct parent. Before creating, you MAY check for an
  existing same-sprint page (CQL `title ~ "Fortnightly Dashboard — S12"` in space AT) and update it instead
  of creating a duplicate. Confirm the parent exists; if "9. Sprint Reports" is missing, create it under 524289 first.
- Direct write is appropriate (internal team workspace). Return the page URL.

## archive-to-Drive (real Office files, plus one plain-text exception)
Write finished artefacts to the **Atlas Shared Drive** (`parentId = 0AGindXMKcjpZUk9PVA`). Two folders:
- **Templates** `1VAXBdsZKsHynwWkXFJcnNDRH09TM0XT9` — blank fill-in forms only.
- **Communication** `10Ow77XB3SVlHGoGnGqr8QLLzSOMKEUDc` — outbound exec communication: the running
  Executive Briefs Log, each fortnight's archived one-pager brief, and archived email copies.
Never confuse the two: templates are blank forms; Communication holds live/sent artefacts.
- **Format per artefact (LOCKED 30-Jul, Log moved to CSV 31-Jul):** browser-viewable team artefacts → NATIVE
  Google Doc/Sheet (omit `disableConversionToGoogleType`, so it opens/edits in the browser); the sponsor's
  **executive brief .docx** → a REAL Office file (`disableConversionToGoogleType: true`), because it's an
  email attachment; the **Executive Briefs Log** → a plain **.csv**, uploaded as text content (no
  `disableConversionToGoogleType` — it isn't binary).
- **How the file gets onto Drive (read "Drive upload mechanics" below FIRST):** the dated brief `.docx` is
  produced by taking a base file, EDITING it in the workspace with the docx skill, and uploading via
  **`create_file` with base64 content passed straight from a `.b64` file on disk** — NOT hand-transcribed.
  The Log `.csv` is plain text, so it uploads via `create_file`'s text-content path directly — no base64, no
  `.b64` relay, no subagent delegation needed. When a Drive file's content is unchanged (pure re-date),
  `copy_file` is the byte-perfect, server-side, no-payload shortcut. Every change is a NEW dated file (the
  connector cannot update in place).
- Build/edit the brief deterministically in code (python-docx) — do NOT hand-assemble args or upload
  text/html for it. The Log is edited as CSV rows (Python's `csv` module or plain string building is fine).
- Never write to My Drive root. If a Shared-Drive write silently lands in My Drive, the
  `supportsAllDrives` flag is the likely cause — surface it, don't claim success.

## send/draft-email (executive delivery)
Prepare the sponsor email via Gmail as a **draft** (`create_draft` / `update_draft` — the connector CANNOT
send autonomously, and this agent MUST NOT).
- **HTML email is the default.** Send an executive-level HTML email with: a navy (`#1F3864`) header band
  showing project name + "Sprint X of Y (closed)"; a **Report date: DD Month YYYY** line (PM's local
  timezone, Asia/Calcutta, the date of the run); a RAG status callout coloured by status (AMBER/RED/GREEN);
  uppercase section dividers; clean bullet rows; and a `Restricted — Internal Use Only · © Atlas` footer.
  ALWAYS also set the plain-text `body` as a fallback.
- **Subject:** leads with the project name and drops the sprint number, e.g.
  `Atlas - Executive Brief: Go-live status & steering asks`.
- **Attach the brief `.docx` automatically — the assistant does it, never the user.** Attach the one-page
  brief via the tool's `attachments` param so the draft is delivered ready-to-send. NEVER write a user-facing
  note like "attach the brief before sending" — the assistant attaches it. (Attachment bytes go via base64
  from a `.b64` file on disk, delegated to a subagent + verified — see "THE UPLOAD METHOD"; never
  hand-transcribe base64.)
- **Recipient** defaults to the PM's own address unless the PM names one; never fabricate addresses.
- Tell the PM it is in Drafts for review — never imply it was sent.

## notify-Slack (generic team notification)
Post a concise notification to a Slack channel (default `#atlas`, ID `C0BLQHPR90U`).
- Generic template fields: `{{title}}` [mandatory], `{{message}}` [mandatory],
  `{{ask}}` [optional], `{{artefact_link}}` [optional]. Post a SUMMARY + link, never a full pack.
- **Draft by default** (`slack_send_message_draft`); direct `slack_send_message` only on explicit
  "post it now". Use Slack mrkdwn.
- **Exception — PM self-notifications go DIRECT, not draft:** a personal heads-up to the PM (e.g. the
  Executive Brief's "your Gmail draft is ready to review & send") is sent DIRECTLY as a **DM to the PM**
  (`slack_send_message` to the PM's DM), not as a draft and not to a channel. Draft-first applies to
  outbound *team/stakeholder* posts; a self-notification to the PM is low-stakes and sends immediately.

## Executive Briefs Log — dated SNAPSHOTS on Drive (connector cannot append/update/delete)
The Drive connector here is **create-only**: no update-by-id, no move, no delete/trash, and there is
NO Google Sheets values API available. So a single running file CANNOT be appended in place. Instead
the Log is kept as a **series of dated snapshot files** in the **Communication** folder
(`10Ow77XB3SVlHGoGnGqr8QLLzSOMKEUDc`):
- **Format (LOCKED, moved to CSV 31-Jul):** the Log is a plain **.csv**, not an Excel file. Rationale: pushing
  the old `.xlsx` through the Drive connector as base64 binary was slow and repeatedly failed/retried (one
  run stalled ~35 minutes on this single step); a CSV uploads via the connector's plain-text path instead —
  no giant base64 string, no retry loop. The RAG-trend chart and second sheet were dropped with it (this is a
  PoC and the sponsor never sees the Log); the RAG-num column stays in the CSV so a trend can be charted on
  demand later if wanted.
- **Naming (LOCKED — ISO-8601 local time, offset in round brackets):**
  `Executive-Briefs-Log-{YYYY-MM-DDThh-mm-ss(±ZZZZ)}.csv`, e.g.
  `Executive-Briefs-Log-2026-07-31T13-08-43(+0530).csv`. Use the **PM's local timezone (Asia/Calcutta,
  +0530), NOT UTC**; round brackets around the offset; zero-padded so it sorts chronologically as text.
  **Latest = most recent timestamp.** (Briefs can be on-demand, not only at sprint end — so timestamp, not sprint number.)
- Each snapshot is SELF-CONTAINED: all rows to date (S10 sample + every logged brief). Not a delta — a full copy.
- **Append procedure each fortnight:** (1) find the latest snapshot by name (most recent timestamp) and READ it
  (`read_file_content` / download) into the workspace; (2) EDIT the CSV — add the new brief row, keeping the
  RAG-num column populated (GREEN=3/AMBER=2/RED=1) so a trend chart can be produced on demand later;
  (3) upload the NEW dated snapshot to the Communication folder as **text content** via `create_file` — plain
  text, so no base64, no `.b64` relay, no subagent delegation. Note the new name so next fortnight reads it back.
- Row fields: Date · Sprint · Overall RAG · Executive one-liner · Recipient(s) · Link to archived brief · Top
  risk · RAG-num (GREEN=3/AMBER=2/RED=1).
- Old snapshots are left in place (no delete tool). This is intentional for the PoC — an audit trail of what
  leadership was told, when.

## Drive upload mechanics — HARD-WON RULES (read before touching Drive)
These are learned workarounds. Follow them exactly; they prevent the failures seen in testing.

### THE UPLOAD METHOD — `create_file` (base64 from disk); `copy_file` for byte-perfect re-dates
**`create_file` with base64 content WORKS** for these files — the templates were seeded that way, and it was
re-verified live (a real `.docx` uploaded via `create_file` returned in well under a second). The old note
claiming base64 `create_file` "hangs on files > a few KB" was a **MISDIAGNOSIS** and is retracted. The real
failure was **base64 transcription corruption**: when the model retypes a file's base64 through its own
reasoning/narration, the string gets truncated or mangled (python-docx/xlsx files are ~15–50KB → ~20–70K
base64 chars, well past what survives hand-relay), and the connector then rejects the corrupt payload. The
tool was never the problem — the relay was.

**Attachment / upload mechanics — NEVER hand-transcribe base64 (this is the part that silently breaks):**
The Gmail/Drive connectors accept file content only as inline base64. base64 corrupts if the model retypes it.
Rule: **never paste a file's base64 into reasoning or output.** Instead:
1. Build/edit the file in the workspace.
2. `base64 -w0 file.docx > file.b64` — one unbroken line, no whitespace, on disk.
3. **Delegate the single `create_file` / `update_draft` call to a subagent** that Reads the `.b64` file and
   passes its exact contents straight into the tool call — the bytes go disk → tool, never through narration.
4. **Verify:** `get_file_metadata` (check `mimeType` + `fileSize`), plus a download + `sha256` round-trip
   against the local file. Retry on mismatch.

**The process for every dated artefact (LOCKED):**
1. **Read** the base file (template, or the previous dated snapshot) into the workspace (`read_file_content` /
   download).
2. **Edit it in the workspace:** the brief `.docx` with python-docx (fill the `[ … ]` placeholders + Atlas
   header/footer); the Log `.csv` as plain text (add the new row, keeping the RAG-num column populated).
3. **Upload:** the brief `.docx`, if content changed, goes via `create_file` with base64 from a `.b64` file on
   disk (per the mechanics above, delegated + verified). The Log `.csv` goes via `create_file` as **text
   content** directly — no base64, no `.b64` relay, no delegation. If either is a pure re-date of an unchanged
   Drive file, `copy_file` is the byte-perfect, server-side, no-payload shortcut and is preferred.
Every change is a NEW dated file — the connector cannot update in place (see CREATE-ONLY below).

Verified live: `copy_file` re-dated a real `.docx` → a dated snapshot (in seconds); `create_file` with
base64-from-disk uploaded a real `.docx` (returned instantly); `create_file` with text content uploaded a
`.csv` Log snapshot without the base64/retry issues the old `.xlsx` path had. All work.

### Format policy
- **Executive brief (.docx, sponsor email attachment)** → REAL Word file (`disableConversionToGoogleType: true`),
  base64 upload, delegated + verified.
- **Executive Briefs Log snapshots (.csv)** → plain text, uploaded as `create_file` text content — no
  `disableConversionToGoogleType`, no base64, no delegation (it isn't binary). Moved off `.xlsx` because
  binary base64 uploads through the Drive connector were slow/unreliable (one run stalled ~35 minutes on
  this step); CSV avoids that path entirely. The RAG-trend chart was dropped with it (PoC; can be charted on
  demand from the RAG-num column).
- **Anything meant to be VIEWED in the browser** → native Google Doc/Sheet (omit the flag).
`copy_file` preserves the source's mimeType, so a real-Office base yields a real-Office copy.

### base64 hygiene (when using `create_file`)
Always `base64 -w0` (no line wrapping / whitespace) to a `.b64` file. Optionally round-trip-verify it decodes
to a valid zip (`zipfile.ZipFile(io.BytesIO(b64decode(s))).testzip() is None`; docx/xlsx are ZIPs, valid bytes
start `UEsDBB`=PK). The ONLY reliable way to pass it is disk → tool via a subagent — never through narration.

### Verify AFTER upload — never assume
Call `get_file_metadata` on the returned id and check `mimeType`:
- want real Office → expect `...wordprocessingml.document` / `...spreadsheetml.sheet`.
- if it came back `application/vnd.google-apps.*`, the flag didn't take — the file got converted.

### "CORRUPTED / DOCS_EVERYWHERE_IMPORT" is NOT corruption
If the user clicks a real .docx/.xlsx in Drive and Google shows "Could not open file… CORRUPTED…
DOCS_EVERYWHERE_IMPORT", that is Google's IN-BROWSER converter failing on a real Office file — the stored
file is intact. Tell the user to DOWNLOAD it (or Open with → Word/Excel). Do NOT treat it as a bad file;
confirm with get_file_metadata + a download (bytes starting `UEsDBB`).

### Connector cannot UPDATE in place — dated new files only
No update-by-id, no move (change parent), no delete/trash, no Sheets values/append API (verified via
registry — only "Google Drive" exists; it does have `copy_file`). Consequence already designed around: the
Log is dated SNAPSHOTS (read latest → edit in workspace → `copy_file` to a new timestamped file), never
appended in place. Deletions are handed to the user.

### Template-in / Office-out workflow (format is decided in CODE, not by the template)
The template's format and the OUTPUT's format are INDEPENDENT. Templates may be **native Google Docs**
(so the user can open/edit them in the browser with no conversion friction). The filled OUTPUT is built
fresh in the workspace and can be a **real MS Office file** regardless of the template's format:
1. **Read** the template from Drive with `read_file_content` (works on native Google Docs AND real .docx —
   returns text, tables, and the `[ … ]` placeholders).
2. **Build the output in code** in the workspace (python-docx for .docx / openpyxl for .xlsx): create the
   document, fill the placeholder content, and APPLY the Atlas header/footer + styling IN THE BUILD SCRIPT
   (header `Atlas — [project_name]` with project name substituted; footer `Restricted — Internal Use Only`
   + page number). Do NOT rely on the template to carry header/footer through a read→rebuild round-trip —
   the build code owns styling, so fidelity is guaranteed independent of the template's format.
3. **Place it on Drive** via `create_file` (base64 from a `.b64` file on disk, delegated + verified — see
   "THE UPLOAD METHOD" above), or `copy_file` if it's an unchanged re-date. The output is a real Office file.
Net: **template → edit in workspace → upload to a dated real .docx/.xlsx.** The user keeps browser-friendly
templates; the sponsor gets a genuine Word/Excel attachment.
