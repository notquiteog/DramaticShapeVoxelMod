import importlib.util
from pathlib import Path
import subprocess
import sys
import tempfile
import types
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('prepare_xd', Path(__file__).parents[1] / 'tools/prepare_xd_pack.py')
wizard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(wizard)


class Prepare(unittest.TestCase):
    def run_case(self, fails):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            disc = root / 'XD (Europe) disc.zip'
            disc.write_bytes(b'unchanged disc')
            output = root / 'ready pack'
            calls = []

            def run(command, check):
                self.assertTrue(check)
                calls.append(command)
                folder = Path(command[command.index('--output') + 1])
                folder.mkdir()
                (folder / 'manifest.json').write_text('{}')
                if fails and len(calls) == 2:
                    raise subprocess.CalledProcessError(1, command)

            parser = types.SimpleNamespace(parser_modules=lambda path: None)
            argv = ['prepare', str(disc), '--output', str(output), '--parser', str(root)]
            with patch.object(sys, 'argv', argv), patch.dict(sys.modules, {'convert_xd_models': parser}), patch.object(wizard.subprocess, 'run', run):
                if fails:
                    with self.assertRaises(subprocess.CalledProcessError):
                        wizard.main()
                    self.assertFalse(output.exists())
                else:
                    self.assertEqual(wizard.main(), 0)
                    self.assertTrue((output / 'manifest.json').exists())
            self.assertEqual(disc.read_bytes(), b'unchanged disc')
            self.assertEqual(len(calls), 2)
            self.assertEqual(calls[0][2], str(disc))
            self.assertEqual(list(root.glob('.xd-prepare-*')), [])

    def test_transactional_success(self):
        self.run_case(False)

    def test_failure_leaves_no_pack(self):
        self.run_case(True)


if __name__ == '__main__':
    unittest.main()
