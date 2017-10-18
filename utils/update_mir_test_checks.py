#!/usr/bin/env python

"""Updates FileCheck checks in MIR tests.

This script is a utility to update MIR based tests with new FileCheck
patterns.

The checks added by this script will cover the entire body of each
function it handles. Virtual registers used are given names via
FileCheck patterns, so if you do want to check a subset of the body it
should be straightforward to trim out the irrelevant parts. None of
the YAML metadata will be checked, other than function names.

If there are multiple llc commands in a test, the full set of checks
will be repeated for each different check pattern. Checks for patterns
that are common between different commands will be left as-is by
default, or removed if the --remove-common-prefixes flag is provided.
"""

from __future__ import print_function

import argparse
import collections
import os
import re
import subprocess
import sys

RUN_LINE_RE = re.compile('^\s*[;#]\s*RUN:\s*(.*)$')
TRIPLE_ARG_RE = re.compile(r'-mtriple[= ]([^ ]+)')
MARCH_ARG_RE = re.compile(r'-march[= ]([^ ]+)')
TRIPLE_IR_RE = re.compile(r'^\s*target\s+triple\s*=\s*"([^"]+)"$')
CHECK_PREFIX_RE = re.compile('--?check-prefix(?:es)?[= ](\S+)')
CHECK_RE = re.compile(r'^\s*[;#]\s*([^:]+?)(?:-NEXT|-NOT|-DAG|-LABEL)?:')

FUNC_NAME_RE = re.compile(r' *name: *(?P<func>[A-Za-z0-9_.-]+)')
BODY_BEGIN_RE = re.compile(r' *body: *\|')
BASIC_BLOCK_RE = re.compile(r' *bb\.[0-9]+.*:$')
VREG_RE = re.compile(r'(%[0-9]+)(?::[a-z0-9_]+)?(?:\([<>a-z0-9 ]+\))?')
VREG_DEF_RE = re.compile(
    r'^ *(?P<vregs>{0}(?:, {0})*) '
    r'= (?P<opcode>[A-Zt][A-Za-z0-9_]+)'.format(VREG_RE.pattern))
PREFIX_DATA_RE = re.compile(r'^ *(;|bb.[0-9].*: *$|[a-z]+: |$)')

MIR_FUNC_RE = re.compile(
    r'^---$'
    r'\n'
    r'^ *name: *(?P<func>[A-Za-z0-9_.-]+)$'
    r'.*?'
    r'^ *body: *\|\n'
    r'(?P<body>.*?)\n'
    r'^\.\.\.$',
    flags=(re.M | re.S))

class LLC:
    def __init__(self, bin):
        self.bin = bin

    def __call__(self, args, ir):
        if ir.endswith('.mir'):
            args = '{} -x mir'.format(args)
        with open(ir) as ir_file:
            stdout = subprocess.check_output('{} {}'.format(self.bin, args),
                                             shell=True, stdin=ir_file)
            # Fix line endings to unix CR style.
            stdout = stdout.replace('\r\n', '\n')
        return stdout


class Run:
    def __init__(self, prefixes, cmd_args, triple):
        self.prefixes = prefixes
        self.cmd_args = cmd_args
        self.triple = triple

    def __getitem__(self, index):
        return [self.prefixes, self.cmd_args, self.triple][index]


def log(msg, verbose=True):
    if verbose:
        print(msg, file=sys.stderr)


def warn(msg, test_file=None):
    if test_file:
        msg = '{}: {}'.format(test_file, msg)
    print('WARNING: {}'.format(msg), file=sys.stderr)


def find_triple_in_ir(lines, verbose=False):
    for l in lines:
        m = TRIPLE_IR_RE.match(l)
        if m:
            return m.group(1)
    return None


def find_run_lines(test, lines, verbose=False):
    raw_lines = [m.group(1)
                 for m in [RUN_LINE_RE.match(l) for l in lines] if m]
    run_lines = [raw_lines[0]] if len(raw_lines) > 0 else []
    for l in raw_lines[1:]:
        if run_lines[-1].endswith("\\"):
            run_lines[-1] = run_lines[-1].rstrip("\\") + " " + l
        else:
            run_lines.append(l)
    if verbose:
        log('Found {} RUN lines:'.format(len(run_lines)))
        for l in run_lines:
            log('  RUN: {}'.format(l))
    return run_lines


def build_run_list(test, run_lines, verbose=False):
    run_list = []
    all_prefixes = []
    for l in run_lines:
        commands = [cmd.strip() for cmd in l.split('|', 1)]
        llc_cmd = commands[0]
        filecheck_cmd = commands[1] if len(commands) > 1 else ''

        if not llc_cmd.startswith('llc '):
            warn('Skipping non-llc RUN line: {}'.format(l), test_file=test)
            continue
        if not filecheck_cmd.startswith('FileCheck '):
            warn('Skipping non-FileChecked RUN line: {}'.format(l),
                 test_file=test)
            continue

        triple = None
        m = TRIPLE_ARG_RE.search(llc_cmd)
        if m:
            triple = m.group(1)
        # If we find -march but not -mtriple, use that.
        m = MARCH_ARG_RE.search(llc_cmd)
        if m and not triple:
            triple = '{}--'.format(m.group(1))

        cmd_args = llc_cmd[len('llc'):].strip()
        cmd_args = cmd_args.replace('< %s', '').replace('%s', '').strip()

        check_prefixes = [item for m in CHECK_PREFIX_RE.finditer(filecheck_cmd)
                          for item in m.group(1).split(',')]
        if not check_prefixes:
            check_prefixes = ['CHECK']
        all_prefixes += check_prefixes

        run_list.append(Run(check_prefixes, cmd_args, triple))

    # Remove any common prefixes. We'll just leave those entirely alone.
    common_prefixes = set([prefix for prefix in all_prefixes
                           if all_prefixes.count(prefix) > 1])
    for run in run_list:
        run.prefixes = [p for p in run.prefixes if p not in common_prefixes]

    return run_list, common_prefixes


def find_functions_with_one_bb(lines, verbose=False):
    result = []
    cur_func = None
    bbs = 0
    for line in lines:
        m = FUNC_NAME_RE.match(line)
        if m:
            if bbs == 1:
                result.append(cur_func)
            cur_func = m.group('func')
            bbs = 0
        m = BASIC_BLOCK_RE.match(line)
        if m:
            bbs += 1
    if bbs == 1:
        result.append(cur_func)
    return result


def build_function_body_dictionary(test, raw_tool_output, triple, prefixes,
                                   func_dict, verbose):
    for m in MIR_FUNC_RE.finditer(raw_tool_output):
        func = m.group('func')
        body = m.group('body')
        if verbose:
            log('Processing function: {}'.format(func))
            for l in body.splitlines():
                log('  {}'.format(l))
        for prefix in prefixes:
            if func in func_dict[prefix] and func_dict[prefix][func] != body:
                warn('Found conflicting asm for prefix: {}'.format(prefix),
                     test_file=test)
            func_dict[prefix][func] = body


def add_checks_for_function(test, output_lines, run_list, func_dict, func_name,
                            single_bb, verbose=False):
    printed_prefixes = set()
    for run in run_list:
        for prefix in run.prefixes:
            if prefix in printed_prefixes:
                continue
            if not func_dict[prefix][func_name]:
                continue
            # if printed_prefixes:
            #     # Add some space between different check prefixes.
            #     output_lines.append('')
            printed_prefixes.add(prefix)
            log('Adding {} lines for {}'.format(prefix, func_name), verbose)
            add_check_lines(test, output_lines, prefix, func_name, single_bb,
                            func_dict[prefix][func_name].splitlines())
            break
    return output_lines


def add_check_lines(test, output_lines, prefix, func_name, single_bb,
                    func_body):
    if single_bb:
        # Don't bother checking the basic block label for a single BB
        func_body.pop(0)

    if not func_body:
        warn('Function has no instructions to check: {}'.format(func_name),
             test_file=test)
        return

    first_line = func_body[0]
    indent = len(first_line) - len(first_line.lstrip(' '))
    # A check comment, indented the appropriate amount
    check = '{:>{}}; {}'.format('', indent, prefix)

    output_lines.append('{}-LABEL: name: {}'.format(check, func_name))

    vreg_map = {}
    for func_line in func_body:
        if not func_line.strip():
            continue
        m = VREG_DEF_RE.match(func_line)
        if m:
            for vreg in VREG_RE.finditer(m.group('vregs')):
                name = mangle_vreg(m.group('opcode'), vreg_map.values())
                vreg_map[vreg.group(1)] = name
                func_line = func_line.replace(
                    vreg.group(1), '[[{}:%[0-9]+]]'.format(name), 1)
        for number, name in vreg_map.items():
            func_line = func_line.replace(number, '[[{}]]'.format(name))
        check_line = '{}: {}'.format(check, func_line[indent:]).rstrip()
        output_lines.append(check_line)


def mangle_vreg(opcode, current_names):
    base = opcode
    # Simplify some common prefixes and suffixes
    if opcode.startswith('G_'):
        base = base[len('G_'):]
    if opcode.endswith('_PSEUDO'):
        base = base[:len('_PSEUDO')]
    # Shorten some common opcodes with long-ish names
    base = dict(IMPLICIT_DEF='DEF',
                GLOBAL_VALUE='GV',
                CONSTANT='C',
                FCONSTANT='C',
                MERGE_VALUES='MV',
                UNMERGE_VALUES='UV',
                INTRINSIC='INT',
                INTRINSIC_W_SIDE_EFFECTS='INT',
                INSERT_VECTOR_ELT='IVEC',
                EXTRACT_VECTOR_ELT='EVEC',
                SHUFFLE_VECTOR='SHUF').get(base, base)

    i = 0
    for name in current_names:
        if name.startswith(base):
            i += 1
    if i:
        return '{}{}'.format(base, i)
    return base


def should_add_line_to_output(input_line, prefix_set):
    # Skip any check lines that we're handling.
    m = CHECK_RE.match(input_line)
    if m and m.group(1) in prefix_set:
        return False
    return True


def update_test_file(llc, test, remove_common_prefixes=False, verbose=False):
    log('Scanning for RUN lines in test file: {}'.format(test), verbose)
    with open(test) as fd:
        input_lines = [l.rstrip() for l in fd]

    triple_in_ir = find_triple_in_ir(input_lines, verbose)
    run_lines = find_run_lines(test, input_lines, verbose)
    run_list, common_prefixes = build_run_list(test, run_lines, verbose)

    simple_functions = find_functions_with_one_bb(input_lines, verbose)

    func_dict = {}
    for run in run_list:
        for prefix in run.prefixes:
            func_dict.update({prefix: dict()})
    for prefixes, llc_args, triple_in_cmd in run_list:
        log('Extracted LLC cmd: llc {}'.format(llc_args), verbose)
        log('Extracted FileCheck prefixes: {}'.format(prefixes), verbose)

        raw_tool_output = llc(llc_args, test)
        if not triple_in_cmd and not triple_in_ir:
            warn('No triple found: skipping file', test_file=test)
            return

        build_function_body_dictionary(test, raw_tool_output,
                                       triple_in_cmd or triple_in_ir,
                                       prefixes, func_dict, verbose)

    state = 'toplevel'
    func_name = None
    prefix_set = set([prefix for run in run_list for prefix in run.prefixes])
    log('Rewriting FileCheck prefixes: {}'.format(prefix_set), verbose)

    if remove_common_prefixes:
        prefix_set.update(common_prefixes)
    elif common_prefixes:
        warn('Ignoring common prefixes: {}'.format(common_prefixes),
             test_file=test)

    autogenerated_note = ('# NOTE: Assertions have been autogenerated by '
                          'utils/{}'.format(os.path.basename(__file__)))
    output_lines = []
    output_lines.append(autogenerated_note)

    for input_line in input_lines:
        if input_line == autogenerated_note:
            continue

        if state == 'toplevel':
            if input_line.strip() == '---':
                state = 'document'
            output_lines.append(input_line)
        elif state == 'document':
            m = FUNC_NAME_RE.match(input_line)
            if m:
                state = 'function metadata'
                func_name = m.group('func')
            if input_line.strip() == '...':
                state = 'toplevel'
                func_name = None
            if should_add_line_to_output(input_line, prefix_set):
                output_lines.append(input_line)
        elif state == 'function metadata':
            if should_add_line_to_output(input_line, prefix_set):
                output_lines.append(input_line)
            m = BODY_BEGIN_RE.match(input_line)
            if m:
                if func_name in simple_functions:
                    # If there's only one block, put the checks inside it
                    state = 'function prefix'
                    continue
                state = 'function body'
                add_checks_for_function(test, output_lines, run_list,
                                        func_dict, func_name, single_bb=False,
                                        verbose=verbose)
        elif state == 'function prefix':
            m = PREFIX_DATA_RE.match(input_line)
            if not m:
                state = 'function body'
                add_checks_for_function(test, output_lines, run_list,
                                        func_dict, func_name, single_bb=True,
                                        verbose=verbose)

            if should_add_line_to_output(input_line, prefix_set):
                output_lines.append(input_line)
        elif state == 'function body':
            if input_line.strip() == '...':
                state = 'toplevel'
                func_name = None
            if should_add_line_to_output(input_line, prefix_set):
                output_lines.append(input_line)

    log('Writing {} lines to {}...'.format(len(output_lines), test), verbose)

    with open(test, 'wb') as fd:
        fd.writelines([l + '\n' for l in output_lines])


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='Show verbose output')
    parser.add_argument('--llc-binary', dest='llc', default='llc', type=LLC,
                        help='The "llc" binary to generate the test case with')
    parser.add_argument('--remove-common-prefixes', action='store_true',
                        help='Remove existing check lines whose prefixes are '
                             'shared between multiple commands')
    parser.add_argument('tests', nargs='+')
    args = parser.parse_args()

    for test in args.tests:
        update_test_file(args.llc, test, args.remove_common_prefixes,
                         verbose=args.verbose)


if __name__ == '__main__':
  main()
