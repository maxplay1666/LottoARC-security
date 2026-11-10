# LottoARC — public security review materials

This repository contains contract source and deployment evidence for security review of LottoARC on Arc Mainnet (chain ID **5042**). It does not contain the website frontend, design assets, media, private configuration, or the development repository's history.

Application: https://lottoarc.vercel.app

## Deployed contracts

| Contract | Address | Review source |
| --- | --- | --- |
| ArcRaffle v6 | `0xdbd36ff02dB7621000cF4A20F49F006472661d41` | [Flattened Solidity](contracts/ArcRaffle_Remix.sol) |
| Pick a Card v4 | `0xacac0e9167113832743d2d2b6f8cdd733c570962` | [Flattened Solidity](contracts/PickACard_Remix.sol) |

USDC: `0x3600000000000000000000000000000000000000`.

### ArcRaffle v6 behavior

- Pool duration: 15 minutes–168 hours. Multiple tickets can be purchased in one transaction.
- A full pool starts a 10-minute countdown. Anyone can request D20 randomness; an authenticated callback makes the result available; anyone can then settle.
- Creator receives 5%, the fixed treasury 0.93%, and the winning ticket receives the remainder, subject to integer rounding. Credits are pull-withdrawable.
- Public creators buy the first ticket and can have one active pool, including a pending draw. The public active-pool limit is 20. Treasury is exempt from these limits and the first-ticket requirement.
- Creators separately fund the native-USDC randomness reserve. Unused reserve is pull-withdrawable. Players cannot cancel individual purchased tickets.

### Evidence and limitations

The included release evidence dates to October 2026; it is not a live status monitor. The raffle deployment record reports exact creation/runtime bytecode matching. The Pick a Card record reports explorer-verified source matching its flattened release file.

Internal raffle validation recorded **161 passing tests**, followed by **7 targeted recheck cases**; this was not a fresh combined 168-test run. These are internal checks, not an independent audit or formal verification. The release records do not establish a completed real-money raffle draw/claim lifecycle.

**Known availability limitation:** if the D20 coordinator permanently stops both result delivery and authenticated failure/refund notification for an outstanding raffle draw, the pot and creator's active slot can remain locked indefinitely. A simple timeout fallback is not a proven safe fix, because it can discard an already determined outcome. The provider's ongoing functionality and upgrade authority are part of the trust model.

The historical raffle explorer-verification submission was blocked; do not confuse bytecode matching with explorer source verification. Pick a Card is a separate contract with separate verification evidence.

## Reproduce compilation

Use Solidity **0.8.28**, optimizer enabled with **200 runs**, and EVM **Cancun**. Each file is flattened and can be compiled independently in Remix. Verify constructor arguments and immutable values against the actual deployment before comparing bytecode. Compiling alone does not prove a contract safe or reproduce deployed immutable values.

`PUBLICATION.json` records SHA-256 hashes of the exported source, evidence, and dependency notices. `python scripts/verify_publication.py` checks the allowlist, hashes, and common credential patterns. Run it after staging changes. The local pre-push hook also inspects reachable Git history. GitHub Actions repeats the check after pushes; CI cannot undo an accidental disclosure, so the local guard and review are essential.

## Publication boundary

The private app repository remains separate. Never copy its `.git` directory or push its branches here. This public repository intentionally has a fresh history. Only files explicitly listed in the verifier may be committed. Frontend code, bundles, source maps, images, video, environment files, deployment credentials, node_modules, and original design assets are excluded.

Published Solidity retains its existing SPDX notices. Third-party license texts are in `LICENSES/`. Public contract source can be read and copied; this repository does not claim otherwise. Publishing contracts does not publish the website implementation or its assets.

See [SECURITY.md](SECURITY.md) for review scope and responsible reporting.
