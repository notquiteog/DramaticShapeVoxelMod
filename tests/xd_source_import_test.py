"""Disc intake checks. These do not certify animated runtime rendering."""
import importlib.util
from pathlib import Path
import struct
import tempfile
import unittest
import zipfile

spec = importlib.util.spec_from_file_location(
    "xd_import", Path(__file__).parents[1] / "tools/import_xd_models.py")
xd = importlib.util.module_from_spec(spec)
spec.loader.exec_module(xd)


class SourceImportTests(unittest.TestCase):
    def test_zip_paths_are_not_extracted(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            archive = root / "disc.zip"
            with zipfile.ZipFile(archive, "w") as z:
                z.writestr("../../escape.rvz", b"RVZ fixture")
                z.writestr("../../unwanted.txt", b"ignore")
            with xd.source_image(archive, root) as p:
                self.assertEqual(p, root / "input.disc")
                self.assertEqual(p.read_bytes(), b"RVZ fixture")
            self.assertFalse((root / "unwanted.txt").exists())

    def test_ambiguous_archive_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            archive = Path(temp) / "disc.zip"
            with zipfile.ZipFile(archive, "w") as z:
                z.writestr("one.iso", b"a")
                z.writestr("two.rvz", b"b")
            with self.assertRaisesRegex(ValueError, "exactly one"):
                with xd.source_image(archive, temp):
                    self.fail("Ambiguous disc accepted")

    def test_compression_overlap_and_truncation(self):
        # Literal A followed by an overlapping reference repeats the new byte.
        payload = b"\x01A\xee\xf2"
        data = b"LZSS" + struct.pack(">III", 6, 16 + len(payload), 0) + payload
        self.assertEqual(xd.lzss(data), b"AAAAAA")
        with self.assertRaises(ValueError):
            xd.lzss(data[:-1])
        corrupt = data[:4] + struct.pack(">I", 4) + data[8:]
        with self.assertRaisesRegex(ValueError, "exceeds"):
            xd.lzss(corrupt)

    def test_bounds_and_bad_archive(self):
        for offset, length in [(-1, 2), (0, -1), (2, 4)]:
            with self.assertRaises(ValueError):
                xd.span(b"abc", offset, length)
        with self.assertRaises(ValueError):
            xd.fsys_entries(b"not an archive")
        with self.assertRaises(ValueError):
            xd.species_table(b"\0" * 32)

    def test_game_ids_and_targets(self):
        self.assertEqual(set(xd.TABLES), {"GXXE01", "GXXP01", "GXXJ01"})
        self.assertEqual(len(set(xd.GAMES)), 11)


if __name__ == "__main__":
    unittest.main()
