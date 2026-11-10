"""Fail closed on unexpected tracked files, changed exports, or obvious credentials."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
EXPORTS = {
    'contracts/ArcRaffle_Remix.sol',
    'contracts/PickACard_Remix.sol',
    'evidence/raffle-v6-mainnet-deployment.json',
    'evidence/pickcard-v4-source-verification.json',
    'LICENSES/OpenZeppelin-MIT.txt',
    'LICENSES/D20-MIT.txt',
}
ALLOWED = EXPORTS | {
    '.gitignore', '.githooks/pre-push', '.github/workflows/publication.yml',
    'README.md', 'SECURITY.md', 'PUBLICATION.json', 'scripts/verify_publication.py',
}
PATTERNS = [
    rb'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----',
    rb'gh[pousr]_[A-Za-z0-9]{30,}',
    rb'github_pat_[A-Za-z0-9_]{40,}',
    rb'AKIA[0-9A-Z]{16}',
    rb'(?i)(?:private_key|mnemonic|seed_phrase)\s*[=:]\s*["\x27][^"\x27]{20,}["\x27]',
]

def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)

def check_blob(name, data):
    if name not in ALLOWED:
        raise ValueError('Unapproved publication path: ' + name)
    if len(data) > 512_000 or b'\x00' in data:
        raise ValueError('Binary or oversized content: ' + name)
    if any(re.search(pattern, data) for pattern in PATTERNS):
        raise ValueError('Possible credential in ' + name + ' (value withheld)')

def verify_index():
    names = set(git('ls-files', '-z').decode().strip('\x00').split('\x00'))
    if names != ALLOWED:
        raise ValueError('Tracked file allowlist mismatch: ' + repr(sorted(names ^ ALLOWED)))
    manifest = json.loads(git('show', ':PUBLICATION.json'))
    if set(manifest['sha256']) != EXPORTS:
        raise ValueError('Manifest export allowlist mismatch')
    for name in sorted(names):
        data = git('show', ':' + name)
        check_blob(name, data)
        if name in EXPORTS and hashlib.sha256(data).hexdigest() != manifest['sha256'][name]:
            raise ValueError('Export hash mismatch: ' + name)

def verify_history():
    commits = git('rev-list', '--all').decode().splitlines()
    seen = set()
    for commit in commits:
        for entry in git('ls-tree', '-rz', commit).split(b'\x00'):
            if not entry:
                continue
            meta, raw_name = entry.split(b'\t', 1)
            mode, kind, oid = meta.decode().split()
            name = raw_name.decode()
            if name not in ALLOWED or kind != 'blob' or mode not in {'100644', '100755'}:
                raise ValueError('Unapproved history entry: ' + name)
            key = (name, oid)
            if key not in seen:
                check_blob(name, git('cat-file', 'blob', oid))
                seen.add(key)
    return len(commits)

if __name__ == '__main__':
    try:
        verify_index()
        count = verify_history() if '--history' in sys.argv else 0
        print(f'PASS: {len(ALLOWED)} allowed files; export hashes and credential patterns checked; {count} history commits checked.')
    except (ValueError, subprocess.CalledProcessError) as error:
        print('PUBLICATION BLOCKED: ' + str(error), file=sys.stderr)
        sys.exit(1)
