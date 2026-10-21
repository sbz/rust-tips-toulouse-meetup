#!/usr/bin/env python3
"""Pre-process slides.md: prepend a line number to every line inside ```rust```
fenced code blocks only. Writes the result to the output path in argv[2]."""
import sys

def main(src, dst):
    with open(src, encoding='utf-8') as f:
        lines = f.readlines()

    out = []
    in_code = False
    lang = None
    lineno = 0
    for line in lines:
        if line.startswith('```'):
            if not in_code:
                in_code = True
                lang = line[3:].strip().split(' ', 1)[0]
                lineno = 0
            else:
                in_code = False
                lang = None
            out.append(line)
            continue
        if in_code and lang == 'rust':
            lineno += 1
            out.append(
                f'{lineno:<2}  {line}' if line.strip() else f'{lineno:<2}  \n'
            )
        else:
            out.append(line)

    with open(dst, 'w', encoding='utf-8') as f:
        f.writelines(out)

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
