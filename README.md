[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits)](https://conventionalcommits.org)
[![Pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://pre-commit.com/)
[![git-cliff - Git Changelog Generator](https://img.shields.io/badge/git--cliff-friendly-brightgreen)](https://git-cliff.org/)


[![CI](https://github.com/Leonardo-Ma/Space-Toilet/actions/workflows/ci.yml/badge.svg)](https://github.com/Leonardo-Ma/Space-Toilet/actions/workflows/ci.yml)

## Development

Refer to this configuration: [Conventional Commit configuration](git-conventional-commits.yaml)

```
<type>(<optional scope>): <description>
empty line as separator
<optional body>
empty line as separator
<optional footer>
```

Example:
```
Feat(inventory): Add inventory system

Uses a matrix

Closes #42
Co-author: JohnDoe
```

### For auto formatter on commit to work (.pre-commit-config.yaml):

Dependencies:
- [python](https://www.python.org/)
- [pipx](https://github.com/pypa/pipx)
- [gdtoolkit](https://github.com/Scony/godot-gdscript-toolkit)
- [pre-commit](https://github.com/pre-commit/pre-commit)

```bash
pip install gdtoolkit pre-commit
pre-commit install
```

### For auto changelog using git-cliff:

Dependencies:
- [pre-commit](https://github.com/pre-commit/pre-commit)
- [rust](https://rust-lang.org/tools/install/)
- [git-cliff](https://github.com/orhun/git-cliff)

```bash
- pre-commit install --hook-type pre-push
```
