"""CPU checks for portable XD conversion; no game assets needed."""
import importlib.util
from pathlib import Path
from types import SimpleNamespace as N
import unittest
import zlib

spec = importlib.util.spec_from_file_location(
    "xd_convert", Path(__file__).parents[1] / "tools/convert_xd_models.py")
xd = importlib.util.module_from_spec(spec)
spec.loader.exec_module(xd)


def key(frame, value, kind="LINEAR", **kw):
    return N(frame=frame, value=value, interpolation=N(value=kind),
             handle_right=kw.get("right"), handle_left=kw.get("left"),
             slope_in=kw.get("slope_in"), slope_out=kw.get("slope_out"))


class Conversion(unittest.TestCase):
    def test_channels(self):
        self.assertEqual(xd.sample([], 4, 7), 7)
        keys = [key(2, 1), key(6, 5)]
        self.assertEqual(xd.sample(keys, 0, 0), 1)
        self.assertEqual(xd.sample(keys, 4, 0), 3)
        self.assertEqual(xd.sample(keys, 9, 0), 5)
        keys[0].interpolation.value = "CONSTANT"
        self.assertEqual(xd.sample(keys, 5, 0), 1)

    def test_cubic_tangents(self):
        keys = [key(0, 0, "BEZIER", slope_out=1),
                key(10, 10, slope_in=1)]
        self.assertAlmostEqual(xd.sample(keys, 3, 0), 3)
        keys[0].handle_right = (10/3, 10/3)
        keys[1].handle_left = (20/3, 20/3)
        self.assertAlmostEqual(xd.sample(keys, 7, 0), 7, places=6)

    def test_paths(self):
        path = N(control_points=[(0, 0, 0), (2, 4, 6)],
                 curve_type=0, num_control_points=2, tension=.5)
        self.assertEqual(xd.spline_point(path, .5), (1, 2, 3))
        self.assertEqual(xd.spline_point(path, 2), (2, 4, 6))
        path.control_points = [(x, 0, 0) for x in range(4)]
        for kind in (1, 2, 3):
            path.curve_type = kind
            self.assertAlmostEqual(xd.spline_point(path, .5)[0], 1.5)
        path.control_points = []
        with self.assertRaises(ValueError):
            xd.spline_point(path, .5)

    def test_texture_orientation(self):
        png = xd.png_rgba(1, 2, bytes([255, 0, 0, 255, 0, 0, 255, 255]))
        start = png.index(b"IDAT")
        length = int.from_bytes(png[start-4:start], "big")
        self.assertEqual(zlib.decompress(png[start+4:start+4+length]),
                         bytes([0, 0, 0, 255, 255, 0, 255, 0, 0, 255]))


if __name__ == "__main__":
    unittest.main()
