# wazo-tools

Tools and scripts developed by the Wazo Team that may be useful to the community.
To avoid maintenance issues, no external scripts will be accepted.
However, improvements to existing ones are always welcome! =)

## Guidelines

- Each project should have its own directory (i.e. no global directory `scripts`/`dev-tools`)
- Scripts should have executable mode
- Write a README.md to explain project
- Naming conventions:
  - use only `-` in the scripts name, not `_`
  - always keep file extension

- Shell scripts should have the following options (pure shell script doesn't
  accept `-o` option):

  ```sh
  set -e
  set -u  # fail if variable is undefined
  set -o pipefail  # fail if command before pipe fails
  ```

## git hooks

Git hooks have been moved to their own repository:
[wazo-platform/wazo-git-hooks](https://github.com/wazo-platform/wazo-git-hooks)
