# Patches for dreamsequence integration

These patches are applied to the **dreamsequence** repository (`/home/sal/dreamsequence`)
to complete the task: "create a card within the repo pages Code Review section"
for defail. The sandbox for this session is restricted to `/home/sal/defail`
writes only (and `/tmp`), so the patches are staged here for application outside
the sandbox (or with an escalated profile).

## Apply

```bash
cd /home/sal/dreamsequence
git apply /home/sal/defail/patches/0001-add-defail-brand.patch
git apply /home/sal/defail/patches/0002-add-defail-to-code-review-group.patch
# verify
npm --prefix dreamsequence-react run build  # or cargo check equivalent
```

## Contents

- `0001-add-defail-brand.patch` — adds `defail` entry to `UNI_TOOL_BRAND` in
  `dreamsequence-react/src/lib/uniToolBrand.ts`
- `0002-add-defail-to-code-review-group.patch` — adds `defail` to the
  `code-review` tool group in `RepositoryDetail.tsx`

Both are intentionally separate so review can evaluate brand vs grouping.

See also `../scripts/install-defail-vps.sh` for the VPS install path (uses
`dreamcred ssh production`).
