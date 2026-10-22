#!/usr/bin/env python3
"""No ROM fixtures: exercise corrupt offsets, sparse files, zone IDs and exports."""
import importlib.util,json,struct,sys,unittest
from pathlib import Path
from types import SimpleNamespace as N
spec=importlib.util.spec_from_file_location('oras_scenery_source',Path(__file__).parents[1]/'tools/oras_scenery_source.py')
m=importlib.util.module_from_spec(spec);sys.modules[spec.name]=m;spec.loader.exec_module(m)

def archive(entries):
    fato=[];fat=bytearray();raw=bytearray();total=0
    for pieces in entries:
        fato.append(len(fat));fat+=struct.pack('<I',sum(1<<bit for bit in pieces))
        for bit,blob in sorted(pieces.items()):
            start=len(raw);raw+=blob;fat+=struct.pack('<III',start,len(raw),len(blob));total+=1
    f=struct.pack('<4sIHH',b'OTAF',12+len(fato)*4,len(fato),0xffff)+struct.pack('<'+'I'*len(fato),*fato)
    b=struct.pack('<4sII',b'BTAF',12+len(fat),total)+fat
    image=struct.pack('<4sII',b'BMIF',12,len(raw))+raw;base=28+len(f)+len(b)+12
    return struct.pack('<4sIHHIIII',b'CRAG',28,0xfeff,0x400,4,base,base+len(raw),len(raw))+f+b+image

def mini(tag,blobs):
    offset=4+(len(blobs)+1)*4;offsets=[offset]
    for b in blobs:offset+=len(b);offsets.append(offset)
    return tag.encode()+struct.pack('<H',len(blobs))+struct.pack('<'+'I'*len(offsets),*offsets)+b''.join(blobs)

class Sources(unittest.TestCase):
    def test_sparse_bits_are_original_ids_including_empty_entries(self):
        a=m.garc(archive([{0:b'a'},{2:b'b',8:b'c'},{}]))
        self.assertEqual(a.logical_count,3)
        self.assertEqual([(e.index,e.bit,e.data)for e in a.entries],[(0,0,b'a'),(1,2,b'b'),(1,8,b'c')])
        with self.assertRaises(m.SourceError):a.single(1)
        with self.assertRaises(m.SourceError):a.single(2)
    def test_reject_truncation_and_repointed_fato(self):
        raw=archive([{0:b'a'},{0:b'b'}])
        for size in [0,27,len(raw)-1]:
            with self.assertRaises(m.SourceError):m.garc(raw[:size])
        bad=bytearray(raw);struct.pack_into('<I',bad,28+16,0)
        with self.assertRaises(m.SourceError):m.garc(bad)
    def test_lz_literals_and_overlapping_backreference(self):
        self.assertEqual(m.decompress(b'\x11\x06\0\0\x10abc\x20\x02'),b'abcabc')
        self.assertEqual(m.decompress(b'\x10\x06\0\0\x10abc\x00\x02'),b'abcabc')
        for raw in [b'\x11\x06\0\0\x80\x20\x02',b'\x11\xff\xff\xff',b'\x11\x06\0\0\x10abc']:
            with self.assertRaises(m.SourceError):m.decompress(raw)
    def test_inner_binary_is_not_misclassified_as_lz(self):
        # Zone map type 0x11 is a binary integer, not a compression marker.
        blob=b'\x11\0\0\0not compressed'
        self.assertEqual(m.mini(mini('ZO',[blob]),'ZO'),[blob])
    def test_matrix_keeps_ffff_holes_and_real_graphics_ids(self):
        data=mini('MM',[struct.pack('<4H4H',0,0,2,2,600,65535,1,2)])
        self.assertEqual(m.matrix(data),{'width':2,'height':2,'graphics':[600,65535,1,2]})
    def test_etc_color_word_order_preserves_a4_words(self):
        a=bytes(range(16))
        self.assertEqual(m.etc_network_order(a,False),a[:8][::-1]+a[8:][::-1])
        self.assertEqual(m.etc_network_order(a,True),a[:8]+a[8:][::-1])
        with self.assertRaises(m.SourceError):m.etc_network_order(a[:7],False)
    def test_glb_keeps_source_channels_and_rejects_missing_textures(self):
        material=N(name='wall',base_color_texture='brick',textures=[N(name='brick')])
        sub=N(material='wall',positions=[(0.,0.,0.),(1.,0.,0.),(0.,1.,0.)],normals=[],uv0=[(0.,0.),(1.,0.),(0.,1.)],uv1=[],uv2=[],colors=[(.2,.3,.4,.5)]*3,triangles=[(0,1,2)])
        model=N(name='room',bones=[],materials=[material],submeshes=[sub]);tex=N(rgba=b'\xff'*4,width=1,height=1)
        with self.assertRaises(m.SourceError):m.glb(model,{},lambda *x:b'PNG')
        blob=m.glb(model,{'brick':tex},lambda *x:b'PNG');magic,version,length=struct.unpack_from('<4sII',blob)
        self.assertEqual((magic,version,length),(b'glTF',2,len(blob)))
        n,=struct.unpack_from('<I',blob,12);doc=json.loads(blob[20:20+n]);prim=doc['meshes'][0]['primitives'][0]
        self.assertEqual(doc['accessors'][prim['attributes']['COLOR_0']]['count'],3)
        self.assertEqual(doc['accessors'][prim['indices']]['count'],3)
        self.assertEqual(doc['images'][0]['name'],'brick')
        sub.triangles=[(0,1,3)]
        with self.assertRaises(m.SourceError):m.glb(model,{'brick':tex},lambda *x:b'PNG')

if __name__=='__main__':unittest.main()
