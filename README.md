<div align="center">
<h1> <b> <i> Space toilet </b> </i> </h1>

[![Conventional Commits][conventional_commits_badge]][conventional_commits_url]
[![Pre-commit][pre_commit_badge]][pre_commit_url]
[![git-cliff - Git Changelog Generator][git_cliff_badge]][git_cliff_url]

[![CI][ci_badge]][ci_url]
[![GitHub release][github_release_badge]](#)

[ci_badge]: https://github.com/Leonardo-Ma/Space-Toilet/actions/workflows/ci.yml/badge.svg
[ci_url]: https://github.com/Leonardo-Ma/Space-Toilet/actions/workflows/ci.yml

[github_release_badge]: https://img.shields.io/github/v/release/leonardo-ma/Space-Toilet
<!----------------------------->
<!-- For future reference -->
<h3>
  <a href="#Summary">Summary</a> |
  <a href="#how-to-use">How To Use</a> |
  <a href="#download">Download</a> |
  <a href="#developing">Developing</a> |
  <a href="#contributing">Contributing</a> |
  <a href="#changelog">Changelog</a> |
  <a href="#contact">Contact</a> |
</h3>
</div>
<!----------------------------->

# Notes
Unreleased (No git tag) didn't follow proper commits good practices considering the amount of constant spread changes that would end up with thousands of small commits.

# Developing
### For auto formatter on commit to work ([.pre-commit-config.yaml](.pre-commit-config.yaml)):

Dependencies:
- [python](https://www.python.org/)
- [pipx](https://github.com/pypa/pipx)
- [gdtoolkit](https://github.com/Scony/godot-gdscript-toolkit)
- [pre-commit](https://github.com/pre-commit/pre-commit)

```bash
pipx install gdtoolkit pre-commit
pipx ensurepath
pre-commit install
```

### For auto changelog using git-cliff:

Dependencies:
- [pre-commit](https://github.com/pre-commit/pre-commit)
- [rust](https://rust-lang.org/tools/install/)
- [git-cliff](https://github.com/orhun/git-cliff)

```bash
pre-commit install --hook-type commit-msg --hook-type pre-push
```

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

# Credits
See [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md).


<!------------------------------------------------------------->
[conventional_commits_badge]: https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?style=for-the-badge&logo=conventionalcommits
[conventional_commits_url]: https://conventionalcommits.org

[pre_commit_badge]: https://img.shields.io/badge/pre--commit-enabled-brightgreen?style=for-the-badge&logo=pre-commit&logoColor=white
[pre_commit_url]: https://pre-commit.com/

[git_cliff_badge]: https://img.shields.io/badge/git--cliff-friendly-brightgreen?style=for-the-badge
[git_cliff_url]: https://git-cliff.org/
