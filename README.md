<div align="center">
<h1> <b> <i> Space toilet </b> </i> </h1>

[![Conventional Commits][conventional_commits_badge]][conventional_commits_url]
[![Keep a Changelog](https://img.shields.io/badge/keep_a_changelog-gray?logo=keepachangelog&logoColor=E05735)](https://keepachangelog.com)  
[![Pre-commit][pre_commit_badge]][pre_commit_url]
[![git-cliff - Git Changelog Generator][git_cliff_badge]][git_cliff_url]  

[![CI][ci_badge]][ci_url]
[![GitHub version][github_release_badge]][changelog]

[ci_badge]: https://github.com/Leonardo-Ma/Untitled-Platformer/actions/workflows/ci.yml/badge.svg
[ci_url]: https://github.com/Leonardo-Ma/Untitled-Platformer/actions/workflows/ci.yml

[github_release_badge]: https://img.shields.io/github/v/release/leonardo-ma/Untitled-Platformer

<!------------------------------------------------->
<h3>
  <a href="#summary">Summary</a> |
  <a href="#developing">Developing</a> |
  <a href="#acknowledgments">Acknowledgments</a> |
</h3>
</div>
<!------------------------------------------------->

This was my first minigame, also to be partially used as a mechanics and architectural template for future ones.
# Summary
xx is a simple 3d low poly plataformer. The core game loop is a partially procedural endless runner around evolving player abilities.

## Features:  
- AI (GOAP and visual detection system)
- Inventory
- Status modifier (Used by buff/debuff/equipment)
- Jump cutting, coyote time, knockback
- Situational music and audio
- Basic UI (Main menu, Pause, debug, hud)
- Basic sound system
- Checkpoint
- Collectibles (Coins, hearts)
- Barebones magic system
- Skills (Multi jump, ground/air dash, feather fall, teleport)
- Chunk based Procedural generation
- Basic score system
To implement:
- Basic map levels
- Skills (hook, fly)?
- Collectible (key?)
- Loot (Equipment)
- Saving system
- UI menu settings, overlay
- Spawn and entity management system
- Achievements
- Combat and peace stances (Different sound, visual and animation)
- Stamina
- In-game diary (For player notes)
- In-game roadmap
- In-game wiki
- Analytics and statistics
- Faction and relationship system

Uses modular approach for future proofing, relying heavily on composition and inheritance when appropriate. Any complex system is documented in `docs/diagrams/`.

Uses conventional commit messages that are fed into git-cliff to auto generate changelog. Has a few CI checks locally and on github and gitlab, has a few unit tests. Strictly follows recommended [code style guidelines](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) and file naming.


# Developing
### For auto formatter on commit to work ([.pre-commit-config.yaml](.pre-commit-config.yaml)):

Dependencies:
- [python](https://www.python.org/)
- [pipx](https://github.com/pypa/pipx)
- [pre-commit](https://github.com/pre-commit/pre-commit)

```bash
pipx install pre-commit
pipx ensurepath
pre-commit install --install-hooks
pre-commit install --hook-type commit-msg
```

### Commit guideline
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

### To use git-cliff (changelog generator) locally:

Dependencies:
- [pre-commit](https://github.com/pre-commit/pre-commit)
- [rust](https://rust-lang.org/tools/install/)
- [git-cliff](https://github.com/orhun/git-cliff)

# Acknowledgments
Refer to [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md).


<!------------------------------------------------------------->
[conventional_commits_badge]: https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white
[conventional_commits_url]: https://conventionalcommits.org

[pre_commit_badge]: https://img.shields.io/badge/pre--commit-enabled-green?logo=pre-commit
[pre_commit_url]: https://pre-commit.com/

[git_cliff_badge]: https://img.shields.io/badge/git--cliff-changelog-green
[git_cliff_url]: https://git-cliff.org/

[changelog]: ./CHANGELOG.md
