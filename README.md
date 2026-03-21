
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)

[![Pre-commit](https://github.com/Leonardo-Ma/Space-Toilet/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/Leonardo-Ma/Space-Toilet/actions/workflows/pre-commit.yml)

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
- python
- gdtoolkit
- pre-commit
```bash
pip install gdtoolkit pre-commit
pre-commit install
```
