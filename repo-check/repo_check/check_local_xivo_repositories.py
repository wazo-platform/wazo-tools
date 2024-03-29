import argparse
import os
from .repositories import xivo_repositories
import sys


class ReposNotFound(Exception):
    def __init__(self, repos):
        self.repos = repos
        super().__init__(f'XiVO repository Not Found exception: missing {repos}')


def main():
    parsed_args = _parse_args()
    assert_no_missing_repos(parsed_args.directory)


def assert_no_missing_repos(directory):
    try:
        missing_repos = _list_missing_repos(directory)
        if missing_repos:
            raise ReposNotFound(missing_repos)

    except OSError:
        print(f'Base directory does not exist : {directory}. Exiting!')
        sys.exit(1)
    except ReposNotFound as e:
        print(f'following xivo repositories could not be found in base directory {directory} : {e.repos}. Exiting!')
        sys.exit(1)


def _list_missing_repos(base_directory):
    dir_list = os.listdir(base_directory)
    existing_repos = {
        directory for directory in dir_list if _is_dir(directory, base_directory)
    }
    required_repos = set(xivo_repositories)
    return list(required_repos - existing_repos)


def _is_dir(directory, base_directory):
    return os.path.isdir(os.path.join(base_directory, directory))


def _parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--directory",
                        help='directory containing all xivo repositories (default : $HOME/xivo_src)',
                        default=os.environ['HOME'] + '/xivo_src')
    return parser.parse_args()


if __name__ == "__main__":
    main()
