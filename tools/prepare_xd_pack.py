#!/usr/bin/env python3
"""Prepare a portable XD pack from one disc/archive selection.

Desktop conversion only. The resulting data needs no Python or disc tools on
Android/iOS. Packs remain gated until rendering acceptance is complete.
"""
import argparse
import os
from pathlib import Path
import subprocess
import sys
import tempfile


def commands(source, output, parser, dolphin, sevenzip, workers, staging):
    tools = Path(__file__).resolve().parent
    source_pack = staging / 'source'
    intake = [sys.executable, str(tools / 'import_xd_models.py'), str(source),
              '--output', str(source_pack)]
    if dolphin:
        intake += ['--dolphin-tool', str(dolphin)]
    if sevenzip:
        intake += ['--sevenzip', str(sevenzip)]
    convert = [sys.executable, str(tools / 'convert_xd_models.py'), str(source_pack),
               '--parser', str(parser), '--output', str(output),
               '--workers', str(workers)]
    return intake, convert


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument('source', nargs='?', type=Path,
                     help='XD disc/archive; omit to select it in a file dialog')
    cli.add_argument('--output', type=Path)
    cli.add_argument('--parser', type=Path, default=os.environ.get('XD_PARSER_PATH'),
                     help='Pinned StarsMmd parser checkout (or XD_PARSER_PATH)')
    cli.add_argument('--dolphin-tool', type=Path)
    cli.add_argument('--sevenzip', type=Path)
    cli.add_argument('--workers', type=int, default=2)
    args = cli.parse_args()
    if not args.parser:
        cli.error('Set XD_PARSER_PATH or pass --parser with the documented parser checkout')
    # Preflight dependencies before touching the large disc archive.
    from convert_xd_models import parser_modules
    parser_modules(args.parser)
    if args.source is None or args.output is None:
        import tkinter as tk
        from tkinter import filedialog
        window = tk.Tk()
        window.withdraw()
        try:
            if args.source is None:
                selected = filedialog.askopenfilename(title='Select your Pokemon XD disc or archive',
                    filetypes=[('XD discs and archives', '*.iso *.gcm *.rvz *.wia *.gcz *.ciso *.zip *.7z')])
                if not selected:
                    return 0
                args.source = Path(selected)
            if args.output is None:
                selected = filedialog.askdirectory(title='Choose where to save the XD model pack')
                if not selected:
                    return 0
                args.output = Path(selected) / 'XD-model-pack'
        finally:
            window.destroy()
    if not args.source.exists():
        cli.error('Source disc/archive does not exist')
    if args.output.exists():
        cli.error('Output already exists; choose a new folder')
    args.output.parent.mkdir(parents=True, exist_ok=True)
    # No partial final pack on failure, and never modify the original disc.
    with tempfile.TemporaryDirectory(prefix='.xd-prepare-', dir=args.output.parent) as temporary:
        staging = Path(temporary)
        output = staging / 'converted'
        for command in commands(args.source.resolve(), output, args.parser.resolve(),
                                args.dolphin_tool, args.sevenzip, args.workers, staging):
            subprocess.run(command, check=True)
        output.rename(args.output)
    print('Prepared:', args.output)
    print('Rendering acceptance is pending; this pack is not enabled in-game yet.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
