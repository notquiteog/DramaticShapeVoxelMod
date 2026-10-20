#!/usr/bin/env python3
"""Prepare a local XD source pack. Geometry conversion/runtime are not yet included.

Requires dolphin-tool for compressed disc images. No game data is downloaded.
Output is transactional and never overwrites an existing pack or source image.
"""
import argparse
import contextlib
import hashlib
import json
import os
from pathlib import Path
import shutil
import struct
import subprocess
import tempfile
import zipfile


GAMES = ["red", "blue", "yellow", "gold", "silver", "crystal",
         "firered", "leafgreen", "ruby", "sapphire", "emerald"]
DISC_SUFFIXES = {".iso", ".gcm", ".rvz", ".wia", ".gcz", ".ciso"}
# Retail revision-0 DOL table offsets, documented by GoD Tool / PKXWZXTables.
# Normal table, normal count, shiny table, shiny count, Unown table/count,
# Deoxys normal/shiny tables, Deoxys count.
TABLES = {
    "GXXE01": (0x40a0a8, 0x41dc78, 0x40cde8, 0x41dc98,
               0x40cd08, 0x41dc90, 0x40ff60, 0x40ff80, 0x41dca0),
    # EU count/Unown/Deoxys addresses corrected against the retail disc:
    # the published table source is four bytes late for these fields.
    "GXXP01": (0x444988, 0x458678, 0x447700, 0x458698,
               0x447620, 0x458690, 0x44a958, 0x44a978, 0x4586a0),
    "GXXJ01": (0x3e7758, 0x3fb310, 0x3ea498, 0x3fb330,
               0x3ea3b8, 0x3fb328, 0x3ed610, 0x3ed630, 0x3fb338),
}


def span(data, offset, length):
    if offset < 0 or length < 0 or offset + length > len(data):
        raise ValueError("Truncated or invalid XD structure")
    return data[offset:offset + length]


def u32(data, offset):
    return struct.unpack(">I", span(data, offset, 4))[0]


def u16(data, offset):
    return struct.unpack(">H", span(data, offset, 2))[0]


def lzss(data):
    """Decode XD's bounded 4-KiB sliding-window stream."""
    if data[:4] != b"LZSS":
        return data
    size, packed = u32(data, 4), u32(data, 8)
    if not 0 < size <= 128 * 1024 * 1024 or packed < 16:
        raise ValueError("Invalid LZSS size")
    stream = span(data, 16, packed - 16)
    window = bytearray(4096)
    output = bytearray()
    cursor, write = 0, 4078
    while len(output) < size:
        flags = span(stream, cursor, 1)[0]
        cursor += 1
        for bit in range(8):
            if len(output) == size:
                break
            if flags & (1 << bit):
                values = span(stream, cursor, 1)
                cursor += 1
                value = values[0]
                output.append(value)
                window[write] = value
                write = (write + 1) % 4096
            else:
                low, high = span(stream, cursor, 2)
                cursor += 2
                source, count = low | ((high & 0xf0) << 4), (high & 15) + 3
                if len(output) + count > size:
                    raise ValueError("LZSS backreference exceeds declared size")
                for i in range(count):
                    value = window[(source + i) % 4096]
                    output.append(value)
                    window[write] = value
                    write = (write + 1) % 4096
    return bytes(output)


def fsys_entries(data):
    if data[:4] != b"FSYS":
        raise ValueError("Not an FSYS archive")
    count, table = u32(data, 12), u32(data, 64)
    if count > 10000:
        raise ValueError("Invalid FSYS entry count")
    entries = {}
    for i in range(count):
        entry = u32(data, table + 4 * i)
        identifier = u32(data, entry)
        name_at = u32(data, entry + 36)
        name = span(data, name_at, min(256, len(data) - name_at)).split(b"\0", 1)[0]
        if identifier in entries:
            raise ValueError("Duplicate FSYS file identifier")
        raw = span(data, u32(data, entry + 4), u32(data, entry + 20))
        entries[identifier] = (name.decode("ascii", "replace"), raw)
    return entries


def species_table(common):
    """Resolve common.rel symbols in relocation order; never guess region offsets."""
    sections = u32(common, 16)
    bases = [u32(common, sections + i * 8) & ~3
             for i in range(u32(common, 12))]
    symbols = []
    seen = set()
    offset = u32(common, 36)
    while True:
        command, section = span(common, offset + 2, 2)
        if command == 203:
            break
        if 1 <= command <= 13:
            if section >= len(bases):
                raise ValueError("Invalid REL section")
            address = bases[section] + u32(common, offset + 4)
            span(common, address, 1)
            if address not in seen:
                symbols.append(address)
                seen.add(address)
        offset += 8
    if len(symbols) <= 89:
        raise ValueError("Missing XD species symbols")
    count = u32(common, symbols[89])
    if not 386 <= count <= 1024:
        raise ValueError("Unexpected XD species count")
    result = {}
    for i in range(count):
        row = symbols[88] + i * 0x124
        dex, model = u16(common, row + 14), u16(common, row + 46)
        if 1 <= dex <= 386:
            result[i] = (dex, model)
    if {dex for dex, _ in result.values()} != set(range(1, 387)):
        raise ValueError("XD species table does not cover all 386 species")
    return result


def build_pack(extracted, destination):
    root, destination = Path(extracted), Path(destination)
    boot = (root / "sys/boot.bin").read_bytes()
    game_id = span(boot, 0, 6).decode("ascii")
    if game_id not in TABLES or boot[7] != 0:
        raise ValueError("Expected a supported retail revision-0 XD US/EU/JP disc")
    if u32(boot, 28) != 0xc2339f3d:
        raise ValueError("Not a GameCube disc")
    dol = (root / "sys/main.dol").read_bytes()
    archives = {}
    for path in sorted((root / "files").rglob("pkx_*.fsys")):
        with path.open("rb") as stream:
            header = stream.read(12)
        if header[:4] == b"FSYS":
            group = u32(header, 8)
            archives.setdefault(group, []).append(path)
    common_entries = fsys_entries((root / "files/common.fsys").read_bytes())
    common = [lzss(raw) for name, raw in common_entries.values() if name == "common_rel"]
    if len(common) != 1:
        raise ValueError("Missing common.rel")
    species = species_table(common[0])
    normal, normal_count, shiny, shiny_count, unown, unown_count, deoxys, deoxys_shiny, deoxys_count = TABLES[game_id]
    count = u32(dol, normal_count)
    if not 386 <= count <= 1024:
        raise ValueError("Invalid model table")
    records, cached = [], {}

    def record(dex, variant, form, table, index, stride=8, skip=0):
        address = table + index * stride + skip
        group, identifier = u32(dol, address), u32(dol, address + 4)
        paths = archives.get(group, [])
        if not paths:
            raise ValueError(f"Missing source model archive for species {dex}")
        if len(paths) != 1:
            raise ValueError(f"Ambiguous model archive for species {dex}")
        path = paths[0]
        if group not in cached:
            cached[group] = fsys_entries(path.read_bytes())
        entry = cached[group].get(identifier)
        if entry is None or ((identifier >> 8) & 255) != 0x1e:
            raise ValueError(f"Missing PKX model entry for species {dex}")
        payload = lzss(entry[1])
        digest = hashlib.sha256(payload).hexdigest()
        output = destination / "pkx" / (digest + ".pkx")
        if not output.exists():
            output.write_bytes(payload)
        records.append({"dex": dex, "variant": variant, "form": form,
                        "path": "pkx/" + output.name, "sha256": digest,
                        "archive": path.name, "fileIdentifier": identifier})

    if destination.exists():
        raise ValueError("Output already exists; choose a new directory")
    destination.mkdir(parents=True)
    (destination / "pkx").mkdir()
    for dex, model in sorted(set(species.values())):
        if model >= count:
            raise ValueError("Species model index outside table")
        if dex == 201:
            record(dex, "normal", "default", unown, 0)
        elif dex == 386:
            record(dex, "normal", "default", deoxys, 0)
        else:
            record(dex, "normal", "default", normal, model)
    for i in range(u32(dol, shiny_count)):
        internal = u16(dol, shiny + i * 12)
        if internal not in species:
            raise ValueError("Unknown shiny exception species")
        record(species[internal][0], "shiny", "default", shiny, i, 12, 4)
    for i in range(u32(dol, unown_count)):
        record(201, "normal", str(i), unown, i)
    for i in range(u32(dol, deoxys_count)):
        record(386, "normal", str(i), deoxys, i)
        record(386, "shiny", str(i), deoxys_shiny, i)
    report = {"format": "xd-source-pack", "version": 1, "gameId": game_id,
              "sourceRevision": boot[7], "targetGames": GAMES,
              "renderReady": False, "speciesCount": len({r["dex"] for r in records}),
              "models": records,
              "note": "Source PKX only. Runtime geometry, animations, particles and UI are pending."}
    (destination / "manifest.json").write_text(json.dumps(report, indent=2) + "\n")
    return report


@contextlib.contextmanager
def source_image(path, temp, sevenzip=None):
    path = Path(path).resolve()
    if path.suffix.lower() in DISC_SUFFIXES:
        yield path
        return
    output = Path(temp) / "input.disc"
    if path.suffix.lower() == ".zip":
        with zipfile.ZipFile(path) as archive:
            candidates = [i for i in archive.infolist() if not i.is_dir()
                          and Path(i.filename).suffix.lower() in DISC_SUFFIXES]
            if len(candidates) != 1:
                raise ValueError("Choose an archive containing exactly one disc image")
            entry = candidates[0]
            if entry.file_size > 2 * 1024**3:
                raise ValueError("XD disc exceeds supported GameCube size")
            # Stream to a fixed path: never extract untrusted archive paths.
            with archive.open(entry) as src, output.open("wb") as dst:
                shutil.copyfileobj(src, dst, 1024 * 1024)
    elif path.suffix.lower() == ".7z":
        executable = sevenzip or shutil.which("7zz") or shutil.which("7z")
        if not executable:
            raise ValueError("Install 7-Zip or unzip the disc image first")
        listing = subprocess.run([executable, "l", "-slt", "--", str(path)],
                                 check=True, capture_output=True, text=True).stdout
        members = [line[7:] for line in listing.splitlines() if line.startswith("Path = ")
                   and Path(line[7:]).suffix.lower() in DISC_SUFFIXES]
        if len(members) != 1:
            raise ValueError("Choose a 7z containing exactly one disc image")
        with output.open("wb") as dst:
            subprocess.run([executable, "x", "-so", "-spd", "--", str(path), members[0]],
                           stdout=dst, check=True)
    else:
        raise ValueError("Supported: ISO/GCM, RVZ, WIA, GCZ, CISO, ZIP and 7z")
    yield output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--dolphin-tool", default=shutil.which("dolphin-tool"))
    parser.add_argument("--sevenzip")
    args = parser.parse_args()
    if args.output.exists():
        parser.error("Output already exists; nothing overwritten")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="xd-import-", dir=args.output.parent) as temp:
        temp = Path(temp)
        if args.source.is_dir():
            extracted = args.source
        else:
            if not args.dolphin_tool:
                parser.error("Install Dolphin's dolphin-tool or pass --dolphin-tool PATH")
            extracted = temp / "disc"
            with source_image(args.source, temp, args.sevenzip) as source:
                subprocess.run([args.dolphin_tool, "extract", "-i", str(source),
                                "-o", str(extracted), "-q"], check=True)
        report = build_pack(extracted, temp / "pack")
        # Publish only after complete table/entry validation.
        if args.output.exists():
            raise ValueError("Output appeared during import; nothing overwritten")
        os.rename(temp / "pack", args.output)
    print(f"Prepared {report['speciesCount']}/386 species, {len(report['models'])} entries.")
    print("Source pack only; not yet a playable model pack.")


if __name__ == "__main__":
    main()
