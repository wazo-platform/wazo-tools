#!/usr/bin/env python3
import argparse
import socket
import sys

Message = list[tuple[str, str]]


def parse_message(lines) -> Message:
    message = []
    for line in lines:
        key, _, value = line.partition(":")
        message.append((key.strip(), value.strip()))
    return message


def format_message(message: Message):
    return "\n".join(f"{key}: {value}" for key, value in message) + "\n\n"


def accumulate_lines(reader):
    line = reader.readline()
    lines = []

    while line.strip() != "":
        lines.append(line)
        line = reader.readline()

    return lines


def read_message(reader) -> Message:
    lines = accumulate_lines(reader)
    return parse_message(lines)


def connect(conn, username, password):
    message = [
        ('Action', 'login'),
        ('Username', username),
        ('Secret', password),
    ]

    data = format_message(message)

    conn.send(data.encode("utf-8"))


def pretty_print(message: Message):
    for line in message:
        print("%s: %s" % line)
    print()


def login_succeeded(message: Message):
    return bool(message) and message[0] == ('Response', 'Success')


def filtered(message: Message, accepted, excluded):
    event_type = next((value for key, value in message if key == 'Event'), None)

    if event_type is None:
        return False

    if len(accepted) > 0:
        return event_type not in accepted

    if len(excluded) > 0:
        return event_type in excluded

    return False


def main():

    parser = argparse.ArgumentParser('read events from AMI')
    parser.add_argument('username')
    parser.add_argument('password')
    parser.add_argument(
        '-e',
        '--exclude',
        default='',
        help='comma-seperated list of events to exclude (Case-sensitive)',
    )
    parser.add_argument(
        '-a',
        '--accept',
        default='',
        help='comma-seperated list of events to accept (Case-sensitive)',
    )
    parser.add_argument('-H', '--host', default='localhost')
    parser.add_argument('-p', '--port', type=int, default=5038)

    args = parser.parse_args()

    excluded = args.exclude.split(',') if args.exclude else []
    accepted = args.accept.split(',') if args.accept else []

    if len(excluded) > 0 and len(accepted) > 0:
        print("ERROR: cannot use exclude and accept list at the same time")
        sys.exit(1)

    conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    conn.connect((args.host, args.port))
    reader = conn.makefile()

    # skip asterisk header
    header = reader.readline()
    print(header, file=sys.stderr)

    print("authenticating...", file=sys.stderr)
    connect(conn, args.username, args.password)
    message = read_message(reader)
    pretty_print(message)
    if not login_succeeded(message):
        print("ERROR: AMI login failed", file=sys.stderr)
        sys.exit(1)

    try:
        while True:
            lines = accumulate_lines(reader)
            if not lines:
                print("connection closed", file=sys.stderr)
                break
            message = parse_message(lines)
            if not filtered(message, accepted, excluded):
                pretty_print(message)
    except KeyboardInterrupt:
        pass
    finally:
        reader.close()
        conn.close()


if __name__ == "__main__":
    main()
