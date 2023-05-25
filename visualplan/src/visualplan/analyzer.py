# Copyright 2013-2023 The Wazo Authors  (see the AUTHORS file)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>

import re


class DialplanExecutionAnalyzer:
    def analyze(self, dialplan_parse_result, log_parse_result):
        line_analyses = self._do_lines_analyses(dialplan_parse_result, log_parse_result)
        return _Analysis(dialplan_parse_result.filename, line_analyses)

    def _do_lines_analyses(self, dialplan_parse_result, log_parse_result):
        line_analyses = []
        for line in dialplan_parse_result.lines:
            is_executed = self._is_line_executed(line, log_parse_result, dialplan_parse_result)
            line_analysis = _LineAnalysis(line.content, line.is_executable, is_executed)
            line_analyses.append(line_analysis)
        return line_analyses

    def _is_line_executed(self, line, log_parse_result, dialplan_parse_result):
        if not line.is_executable:
            return False
        elif line.extension.startswith('_'):
            pattern = line.extension[1:]
            for extension in log_parse_result.list_executed_extensions(line.context, line.priority):
                if not dialplan_parse_result.has_extension(line.context, extension) and\
                    _is_extension_match_pattern(extension, pattern):
                    return log_parse_result.is_executed(line.context, extension, line.priority)
            return False
        else:
            return log_parse_result.is_executed(line.context, line.extension, line.priority)


def _is_extension_match_pattern(extension, pattern):
    regex_pattern = _convert_ast_pattern_to_regex_pattern(pattern)
    return bool(re.match(regex_pattern, extension))


def _convert_ast_pattern_to_regex_pattern(ast_pattern):
    regex_pattern_list = [r'^']
    index = 0
    length = len(ast_pattern)
    while index < length:
        cur_char = ast_pattern[index]
        if cur_char == r'X':
            regex_pattern_list.append(r'[0-9]')
        elif cur_char == r'Z':
            regex_pattern_list.append(r'[1-9]')
        elif cur_char == r'N':
            regex_pattern_list.append(r'[2-9]')
        elif cur_char == r'[':
            close_index = ast_pattern.find(r']', index)
            regex_pattern_list.append(fr'[{ast_pattern[index:close_index]}]')
            index += close_index
        elif cur_char == r'.':
            regex_pattern_list.append(r'.+')
            break
        elif cur_char == r'!':
            regex_pattern_list.append(r'.*')
            break
        else:
            regex_pattern_list.append(re.escape(cur_char))
        index += 1
    regex_pattern_list.append(r'$')
    return r''.join(regex_pattern_list)


class _Analysis:
    def __init__(self, filename, line_analyses):
        self.filename = filename
        self.line_analyses = line_analyses


class _LineAnalysis:
    def __init__(self, content, is_executable, is_executed):
        self.content = content
        self.is_executable = is_executable
        self.is_executed = is_executed
