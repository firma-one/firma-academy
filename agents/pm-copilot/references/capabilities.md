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

## archive-to-Drive (real Office files only)
Write finished artefacts to the **Atlas Shared Drive** (`parentId = 0AGindXMKcjpZUk9PVA`). Two folders:
- **Templates** `1VAXBdsZKsHynwWkXFJcnNDRH09TM0XT9` — blank fill-in forms only.
- **Communication** `10Ow77XB3SVlHGoGnGqr8QLLzSOMKEUDc` — outbound exec communication: the running
  Executive Briefs Log, each fortnight's archived one-pager brief, and archived email copies.
Never confuse the two: templates are blank forms; Communication holds live/sent artefacts.
- **Format per artefact (LOCKED 30-Jul):** browser-viewable team artefacts → NATIVE Google Doc/Sheet
  (omit `disableConversionToGoogleType`, so it opens/edits in the browser); the sponsor's **executive
  brief .docx** and the **Executive Briefs Log .xlsx** → REAL Office files (`disableConversionToGoogleType: true`),
  because the brief is an email attachment and the Log carries a live chart.
- **How the file gets onto Drive — `copy_file`, not base64 (read "Drive upload mechanics" below FIRST):**
  base64 `create_file` **hangs on files more than a few KB**, so it is avoided. The dated artefact is produced
  by taking the base file already on Drive, EDITING it in the workspace with the xlsx/docx skill (add the Log
  row / fill the brief), and using **`copy_file`** to place it under the new dated name (server-side, instant,
  no payload). Every change is a NEW dated file (the connector cannot update in place).
- Build/edit the file deterministically in code (python-docx / openpyxl) — do NOT hand-assemble args or
  upload text/html.
- Never write to My Drive root. If a Shared-Drive write silently lands in My Drive, the
  `supportsAllDrives` flag is the likely cause — surface it, don't claim success.

## send/draft-email (executive delivery)
Prepare the sponsor email via Gmail.
- Tool: `create_draft` only — the connector CANNOT send autonomously, and this agent MUST NOT.
- **Subject line convention (MANDATORY):** every email subject starts with `Atlas - ` then the topic,
  e.g. `Atlas - Sprint 12 Executive Brief`, `Atlas - Go-live status & steering asks`.
- Confirm recipient(s) with the PM; never fabricate addresses. Attach the supporting brief .docx.
- Tell the PM it is in Drafts for review — never imply it was sent.

## notify-Slack (generic team notification)
Post a concise notification to a Slack channel (default `#atlas`, ID `C0BLQHPR90U`).
- Generic template fields: `{{title}}` [mandatory], `{{message}}` [mandatory],
  `{{ask}}` [optional], `{{artefact_link}}` [optional]. Post a SUMMARY + link, never a full pack.
- **Draft by default** (`slack_send_message_draft`); direct `slack_send_message` only on explicit
  "post it now". Use Slack mrkdwn.

## Executive Briefs Log — dated SNAPSHOTS on Drive (connector cannot append/update/delete)
The Drive connector here is **create-only**: no update-by-id, no move, no delete/trash, and there is
NO Google Sheets values API available. So a single running file CANNOT be appended in place. Instead
the Log is kept as a **series of dated snapshot files** in the **Communication** folder
(`10Ow77XB3SVlHGoGnGqr8QLLzSOMKEUDc`):
- Naming: `Executive-Briefs-Log-{YYYY-MM-DD--HH-MM}.xlsx` (UTC, zero-padded so the name sorts chronologically as text). **Latest = most recent timestamp.** (Briefs can be on-demand, not only at sprint end — so timestamp, not sprint number.)
- Each snapshot is SELF-CONTAINED: all rows to date (S10 sample + every logged brief) PLUS the updated
  RAG-trend chart. Not a delta — a full copy.
- **Append procedure each fortnight:** (1) find the latest snapshot by name (most recent timestamp) and READ it
  (`read_file_content` / download) into the workspace; (2) EDIT the workbook with the xlsx skill/openpyxl —
  add the new brief row and set the RAG-num in col H (GREEN=3/AMBER=2/RED=1) so the trend chart extends;
  (3) `copy_file` to place the NEW dated snapshot `Executive-Briefs-Log-{YYYY-MM-DD--HH-MM}.xlsx` in the
  Communication folder (server-side, instant, no base64). Note the new name so next fortnight reads it back.
  (`copy_file` is the upload mechanism — see "Drive upload mechanics" below; base64 `create_file` is avoided.)
- Row fields: Date · Sprint · Overall RAG · Executive one-liner · Recipient(s) · Link to archived brief · Top risk.
- Old snapshots are left in place (no delete tool). This is intentional for the PoC — it also demonstrates
  the agent archiving real Office files to Drive. Purpose: RAG trend + audit trail of what leadership was told, when.

## Drive upload mechanics — HARD-WON RULES (read before touching Drive)
These are learned workarounds. Follow them exactly; they prevent the failures seen in testing.

### THE UPLOAD METHOD — `copy_file`, not base64 `create_file` (verified live 30-Jul)
`create_file` with a `base64Content` payload **HANGS** the connector on any file more than a few KB
(an ~11KB .xlsx never returned; time was lost on this repeatedly). Do NOT push files up as base64.
`copy_file` returns **instantly** — Drive copies the bytes server-side, there is NO payload in the request.

**The process for every dated artefact (LOCKED):**
1. **Read** the base file already on Drive (the template, or the previous dated snapshot) with
   `read_file_content` / download, into the workspace.
2. **Edit it in the workspace** with the xlsx/docx skill (openpyxl / python-docx): add the new Log row and
   set col-H RAG-num so the chart extends, or fill the brief's `[ … ]` placeholders + Atlas header/footer.
3. **`copy_file`** to place the result under the new dated name in the target folder — instant, no base64:
   `copy_file(fileId=<base on Drive>, title="Executive-Briefs-Log-{YYYY-MM-DD--HH-MM}.xlsx", parentId=<Communication>)`.
   `copy_file` preserves the source's mimeType, so a real `.xlsx`/`.docx` base yields a real `.xlsx`/`.docx` copy.
Every change is a NEW dated file — the connector cannot update in place (see CREATE-ONLY below).

Proven live: copied `Executive-Briefs-Log.xlsx` → `Executive-Briefs-Log-2026-07-30--18-45.xlsx`
(id `1-3DgZegqNhTFICX-FO0erVAVCiwXamtk`), real .xlsx, 11092 bytes, in Communication — returned in seconds.

### Format policy (the base file's format carries through `copy_file`)
Because `copy_file` preserves mimeType, format is set ONCE when the base file first lands on Drive, then
inherited by every copy. Policy per artefact:
- **Executive brief (.docx, sponsor email attachment)** → REAL Word file.
- **Executive Briefs Log snapshots (.xlsx)** → REAL Excel file (keeps the chart).
- **Anything meant to be VIEWED in the browser** → native Google Doc/Sheet.
(The one-time base upload uses `disableConversionToGoogleType: true` for real Office, omitted for native
Google. That flag matters only for that first upload; after that `copy_file` carries it.)

### base64 `create_file` — AVOID (documented only for the rare one-time base upload)
If a base file must be created from workspace bytes (no Drive source to copy), `create_file` + base64 is the
only path — but it hangs on non-trivial files, so keep such uploads tiny or do them out of band. If ever used:
strip ALL whitespace from the base64 (`tr -d ' \n\r\t'`) and round-trip-verify it decodes to a valid zip
(`zipfile.ZipFile(io.BytesIO(b64decode(s))).testzip() is None`; docx/xlsx are ZIPs, valid bytes start `UEsDBB`=PK).
Never make base64 `create_file` the routine upload path — `copy_file` is.

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
3. **Place it on Drive with `copy_file`** to the new dated name (see "THE UPLOAD METHOD" above) — not base64.
   The base template lives on Drive as a real Office file, so the copy inherits real `.docx`/`.xlsx`.
Net: **template on Drive → edit in workspace → `copy_file` to dated real .docx/.xlsx out.** The user keeps
browser-friendly templates; the sponsor still gets a genuine Word/Excel attachment. No base64 in the loop.
