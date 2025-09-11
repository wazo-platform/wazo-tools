# import sqlglot
import re
import sys
from collections.abc import Iterator

CHECK_CONSTRAINT = re.compile(r'CONSTRAINT \w+ CHECK \((.*?)\)$')
MEMBERCHECK = re.compile(r"\(\((?P<column>\w+)\).*? = ANY \(\(ARRAY\[(?P<values>.*)\]\).*?\)")


def process_sql_dump(sql_text: str) -> Iterator[str]:
    for line in sql_text.split('\n'):
        match = CHECK_CONSTRAINT.search(line)

        if match:
            # yield (line)
            # check_expr = match.group(1)
            def replace_member_check(match):
                column = match.group('column')
                values = match.group('values')
                values = re.findall(r"('\w+')[^,]*,?", values)
                return f"{column} IN ({', '.join(values)})"

            new_line = re.sub(MEMBERCHECK, replace_member_check, line)
            yield new_line

        else:
            yield line


def main():
    sql_text = sys.stdin.read()
    line_count = len(sql_text.split('\n'))

    for i, line in enumerate(process_sql_dump(sql_text)):
        print(line)

    assert i == line_count - 1, f"{i} != {line_count -1}"


if __name__ == '__main__':
    main()
