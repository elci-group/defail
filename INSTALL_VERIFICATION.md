# Install & Card Verification

## Patches (Code Review card)

Both patches verify with `git apply --check`:

```bash
cd /home/sal/dreamsequence
git apply --check /home/sal/defail/patches/0001-add-defail-brand.patch  # exit 0
git apply --check /home/sal/defail/patches/0002-add-defail-to-code-review-group.patch  # exit 0
```

Apply:

```bash
git apply /home/sal/defail/patches/0001-add-defail-brand.patch
git apply /home/sal/defail/patches/0002-add-defail-to-code-review-group.patch
```

Result:
- `dreamsequence-react/src/lib/uniToolBrand.ts` gains `defail` brand entry
- `dreamsequence-react/src/pages/RepositoryDetail.tsx` adds `defail` to `code-review` group
- Card appears in Repo Pages → Repository Detail → Code Review section alongside chakra/ferret/vamos/traci/tempcheq/obserde-compat

## VPS Install (dreamcred)

The install script `scripts/install-defail-vps.sh` uses the declared dreamcred path:

```bash
# preferred: the script wraps dreamcred ssh production itself
./scripts/install-defail-vps.sh
# manual equivalent — `-- --local` is required so the script runs its remote
# payload on the VPS instead of re-wrapping it in another ssh hop
dreamcred ssh production -- bash -s -- --local < scripts/install-defail-vps.sh
```

Sandbox note (this session):
- The bwrap sandbox is `proxy-only` with `--unshare-net` and `Read-only file system` for `/home/sal/.local/share/dreamcred`.
  Direct verification (`ssh dreamsequence-vps`, `cargo build`, `gpg --decrypt`) is blocked:
  - `ssh: connect to host 217.160.100.202 port 22: Network is unreachable`
  - `gpg: can't connect to the gpg-agent: General error` (sandbox ro-bind)
  - `cargo: could not exec the linker cc: Operation not permitted` (seccomp)
- Previous session audit verified defail itself: 82 tests green, `cargo clippy -- -D warnings` clean, `deliver --spec deliver.toml --strict` 18/18.
- VPS connectivity and cargo execution succeed outside the sandbox (on workstation or VPS). Run the script from an unsandboxed shell to verify:

```bash
# from /home/sal/defail, outside Muse sandbox
./scripts/install-defail-vps.sh
# verify on VPS
dreamcred ssh production -- /usr/local/bin/defail demo baker --late
dreamcred ssh production -- /usr/local/bin/defail --help
```

