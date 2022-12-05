# wazo-tools

## Guidelines

* Each project should have its own directory (i.e. no global directory `scripts`/`dev-tools`)
* Scripts should have executable mode
* Write a README.md to explain project
* Naming conventions:
  * use only `-` in the scripts name, not `_`
  * always keep file extension
* Shell scripts should have the following options (pure shell script doesn't accept `-o` option):

  ```
  set -e
  set -u  # fail if variable is undefined
  set -o pipefail  # fail if command before pipe fails
  ```

## git hooks
Git hook scripts are provided in the `git-hooks` subdirectory.
They can be installed manually (see [`git-hooks/README.md`](git-hooks/README.md)).
They are also made available for use through the [pre-commit framework](https://pre-commit.com/) thanks to the `.pre-commit-hooks.yml` manifest file.

A sample pre-commit configuration to use those hooks:
```yaml
# File .pre-commit-config.yaml
# See https://pre-commit.com for more information
# See https://pre-commit.com/hooks.html for more hooks
repos:
- repo: https://github.com/wazo-platform/wazo-tools.git
  # pre-commit will complain about mutable reference, a specific tag or commit hash can be used instead
  rev: master 
  hooks:
  - id: wazo-copyright-check
  - id: wazo-changelog-check
  - id: wazo-local-docker-volume-check
```

# TODO

* move `./dev-tools/repos` to release repository
    * warning: automated process use directly github
* move `./scripts/import-pjsip-config.py` to its own directory
    * warning: people use directly github
