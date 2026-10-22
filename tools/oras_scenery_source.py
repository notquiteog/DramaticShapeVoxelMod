#!/usr/bin/env python3
"""Audit/extract scenery from a user-supplied decrypted ORAS RomFS.

No game data or decoder code is bundled. inventory is stdlib-only; zone exports
use an explicitly supplied external n3ds_importer checkout, never auto-download.
Exports are review intermediates, not approved native-map replacements.
"""
from __future__ import annotations
import argparse, hashlib, json, math, struct, sys
from dataclasses import dataclass
from pathlib import Path

ARCHIVES = {'zones':'a/0/1/3', 'areas':'a/0/1/4', 'objects':'a/0/2/3',
            'graphics':'a/0/3/9', 'matrices':'a/0/4/0'}
MAX_BLOB = 128 * 1024 * 1024

class SourceError(ValueError): pass

def need(condition, message):
    if not condition: raise SourceError(message)

def sha(data): return hashlib.sha256(data).hexdigest()

def unpack(fmt, data, offset):
    need(offset >= 0 and offset + struct.calcsize(fmt) <= len(data), 'truncated structure')
    return struct.unpack_from(fmt, data, offset)

@dataclass(frozen=True)
class Entry:
    index: int
    bit: int
    data: bytes

@dataclass
class Garc:
    logical_count: int
    entries: list[Entry]

    def single(self, index):
        hits = [e for e in self.entries if e.index == index]
        need(len(hits) == 1 and hits[0].bit == 0, f'entry {index}: expected one bit-0 file')
        return hits[0].data


def garc(data):
    """GARC v4, using FATO offsets and actual FATB bit positions (including holes)."""
    need(len(data) <= MAX_BLOB and data[:4] == b'CRAG', 'not a bounded GARC')
    hs,bom,version,sections,base,size,largest=unpack('<IHHIIII',data,4)
    need(hs == 28 and bom == 0xfeff and version == 0x400 and sections == 4,
         'unsupported GARC header/version')
    need(size == len(data) and base <= size, 'GARC size/data offset mismatch')
    need(data[hs:hs+4] == b'OTAF', 'missing FATO')
    fs,count=unpack('<IH',data,hs+4)
    need(fs == 12+count*4 and hs+fs <= size, 'invalid FATO size')
    offsets=unpack('<'+str(count)+'I',data,hs+12)
    bp=hs+fs
    need(data[bp:bp+4] == b'BTAF', 'missing FATB')
    bs,total=unpack('<II',data,bp+4)
    need(bs >= 12 and bp+bs+12 == base, 'invalid FATB/data layout')
    need(data[bp+bs:bp+bs+4] == b'BMIF', 'missing FIMB')
    fhs,ds=unpack('<II',data,bp+bs+4)
    need(fhs == 12 and ds == size-base, 'invalid FIMB size')
    entries=[];cursor=0
    for index,off in enumerate(offsets):
        need(off == cursor, 'FATO/FATB offset mismatch')
        bits,=unpack('<I',data,bp+12+off);cursor += 4
        for bit in range(32):
            if not (bits >> bit & 1): continue
            start,end,length=unpack('<III',data,bp+12+cursor);cursor += 12
            need(cursor <= bs-12 and start <= end <= ds and length <= end-start,
                 'out-of-range GARC subfile')
            entries.append(Entry(index,bit,data[base+start:base+start+length]))
    need(cursor == bs-12 and len(entries) == total, 'FATB count/size mismatch')
    return Garc(count,entries)


def decompress(data):
    """Strict LZ10/LZ11; reject truncated streams and invalid back references."""
    layers=0
    while data and data[0] in (0x10,0x11):
        layers+=1;need(layers<=4,'nested compression limit')
        kind=data[0];size=int.from_bytes(data[1:4],'little');pos=4
        need(len(data)>=4,'truncated LZ header')
        if size == 0: size,=unpack('<I',data,4);pos=8
        need(0<size<=MAX_BLOB,'LZ size exceeds budget')
        out=bytearray()
        def byte():
            nonlocal pos
            need(pos<len(data),'truncated LZ payload');v=data[pos];pos+=1;return v
        while len(out)<size:
            flags=byte()
            for mask in (128,64,32,16,8,4,2,1):
                if len(out)==size: break
                if not flags&mask: out.append(byte());continue
                a=byte();n=a>>4
                if kind==0x10:
                    length=n+3;distance=((a&15)<<8|byte())+1
                elif n==0:
                    b=byte();c=byte();length=((a&15)<<4|(b>>4))+0x11;distance=((b&15)<<8|c)+1
                elif n==1:
                    b=byte();c=byte();d=byte();length=((a&15)<<12|b<<4|c>>4)+0x111;distance=((c&15)<<8|d)+1
                else:
                    length=n+1;distance=((a&15)<<8|byte())+1
                need(distance<=len(out) and len(out)+length<=size,'invalid LZ back reference')
                for _ in range(length): out.append(out[-distance])
        data=bytes(out)
    return data


def mini(data, tag):
    data=decompress(data)
    need(data[:2] == tag.encode('ascii'), f'expected {tag} container')
    n,=unpack('<H',data,2)
    need(0<n<=255,'invalid mini container count')
    offsets=unpack('<'+str(n+1)+'I',data,4)
    need(offsets[0]>=4+(n+1)*4 and offsets[-1]<=len(data), 'mini offset bounds')
    need(all(a<=b for a,b in zip(offsets,offsets[1:])), 'unordered mini offsets')
    return [data[a:b]for a,b in zip(offsets,offsets[1:])]


def matrix(data):
    s=mini(data,'MM')[0]
    _,_,w,h=unpack('<HHHH',s,0)
    need(0<w*h<=4096,'matrix dimension budget')
    ids=unpack('<'+str(w*h)+'H',s,8)
    return {'width':w,'height':h,'graphics':list(ids)}


class Source:
    def __init__(self, root):
        self.root=Path(root);self.archives={};self.hashes={}
        for key,rel in ARCHIVES.items():
            data=(self.root/rel).read_bytes();self.hashes[key]=sha(data)
            self.archives[key]=garc(data)
        self.matrices={e.index:matrix(e.data)for e in self.archives['matrices'].entries if e.bit==0}
        self.zones={}
        for e in self.archives['zones'].entries:
            raw=decompress(e.data)
            if raw[:2]!=b'ZO':continue # archive also holds its aggregate lookup table
            z=mini(raw,'ZO')[0]
            need(len(z)==56,'unexpected zone data length')
            area,mat=unpack('<HH',z,2)
            need(area<self.archives['areas'].logical_count and mat in self.matrices,'zone link out of bounds')
            self.zones[e.index]={'area':area,'matrix':mat,'type':z[0]}
    def report(self):
        return {'schema':1,'game':'Pokemon Alpha Sapphire / Omega Ruby',
          'archives':{k:{'path':ARCHIVES[k],'sha256':self.hashes[k],
          'logicalEntries':a.logical_count,'subfiles':len(a.entries),
          'nonempty':sum(bool(e.data)for e in a.entries)}for k,a in self.archives.items()},
          'zoneCount':len(self.zones),'zones':self.zones,'matrices':self.matrices}


def etc_network_order(raw, alpha):
    # 3DS stores each 64-bit ETC color word little endian. The external ETC
    # routine expects network byte order. A4 words retain their original order.
    stride=16 if alpha else 8
    need(len(raw)%stride==0,'truncated ETC block')
    data=bytearray(raw)
    for i in range(stride-8,len(data),stride):data[i:i+8]=data[i:i+8][::-1]
    return bytes(data)


def decoder(path):
    path=Path(path).resolve()
    need((path/'ctr/formats/bch/lower.py').is_file(),'decoder must be n3ds_importer checkout root')
    sys.path.insert(0,str(path))
    from ctr.formats.bch.lower import _lower_model
    from ctr.formats.bch.texture import read_textures
    from ctr import ir
    from ctr.formats.bch.model import read_models
    from ctr.formats.bch.mesh import read_meshes
    from ctr.pica.attributes import AttributeName
    from ctr.formats.bch.material import Material as RawMaterial
    from ctr.formats.bch.header import read_header,relocate
    from ctr.formats.bch.contents import read_contents
    from ctr.binstream import BinStream
    from ctr.image.png import encode_rgba
    need(Path(sys.modules['ctr'].__file__).resolve().is_relative_to(path),'unexpected decoder module location')
    def models(blob):
        h=read_header(BinStream(blob));need(h.backward==0x21,'unreviewed BCH version');data=relocate(blob,h);c=read_contents(data,h)
        raws=read_models(data,c)
        need(len(raws)==c.models.count,'decoder skipped source models')
        # n3ds_importer a68959e assumes legacy materials. ORAS BCH 0x21 stores
        # 44-byte inline records rather than the older 88-byte representation.
        # Decode only the identity/reference fields; do not invent TEV state.
        modern=h.backward>=0x21;stride=44 if modern else 88
        for i,raw in enumerate(raws):
            at,=unpack('<I',data,c.models.values+i*4)
            start,count,_=unpack('<III',data,at+52)
            refs=28 if modern else 72;name_at=40 if modern else 84
            def text(pointer):
                if pointer==0:return ''
                need(pointer<len(data),'material string outside BCH')
                end=data.find(b'\0',pointer);need(end>=pointer,'unterminated material name')
                return bytes(data[pointer:end]).decode('utf-8',errors='strict')
            raw.materials=[]
            for j in range(count):
                base=start+j*stride
                names=[text(v)for v in unpack('<III',data,base+refs)]
                raw.materials.append(RawMaterial(name=text(unpack('<I',data,base+name_at)[0]),textures=names))
            need([x.name for x in raw.materials]==raw.material_names,'material dictionary order mismatch')
            for mesh in read_meshes(data,raw):
                need(not any(a.name==AttributeName.TexCoord2 for a in mesh.attributes),'unreviewed third UV channel')
        return [_lower_model(data,raw)for raw in raws]
    def textures(blob):
        h=read_header(BinStream(blob));need(h.backward==0x21,'unreviewed texture BCH version');c=read_contents(relocate(blob,h),h)
        ts=read_textures(relocate(blob,h),c)
        need(len(ts)==c.textures.count,'decoder skipped source textures')
        out=[]
        for t in ts:
            need(t.width*t.height*4<=MAX_BLOB,'texture dimension budget')
            if int(t.fmt) in (12,13):t.raw=etc_network_order(t.raw,int(t.fmt)==13)
            out.append(ir.Texture(name=t.name,width=t.width,height=t.height,rgba=bytes(t.to_rgba())))
        return out
    return models,textures,encode_rgba


def glb(model, textures, png):
    """Review GLB: source positions, all UVs/colors, base texture; no geometry edits.

    Does not emulate PICA TEV, UV animation, source alpha/cull/sampler state.
    These are recorded as limitations, never silently promoted to runtime assets.
    """
    need(not model.bones,'skinned/rigid model requires reviewed bone transforms')
    doc={'asset':{'version':'2.0','generator':'Battle Art ORAS local source review'},
         'extensionsUsed':['KHR_materials_unlit'],'buffers':[{'byteLength':0}],
         'bufferViews':[],'accessors':[],'images':[],'textures':[],
         'samplers':[{'magFilter':9728,'minFilter':9728,'wrapS':10497,'wrapT':10497}],
         'materials':[],'meshes':[],'nodes':[],'scenes':[{'nodes':[]}],'scene':0}
    raw=bytearray()
    def view(data,target=None):
        raw.extend(b'\0'*((-len(raw))%4));offset=len(raw);raw.extend(data)
        v={'buffer':0,'byteOffset':offset,'byteLength':len(data)}
        if target:v['target']=target
        doc['bufferViews'].append(v);return len(doc['bufferViews'])-1
    def attr(rows,width,kind=5126):
        need(rows and all(len(r)==width for r in rows),'invalid attribute dimensions')
        need(all(math.isfinite(v)for r in rows for v in r),'nonfinite attribute')
        packed=struct.pack('<'+str(len(rows)*width)+('f'if kind==5126 else'I'),*(v for r in rows for v in r))
        a={'bufferView':view(packed,34963 if kind==5125 else 34962),'componentType':kind,
           'count':len(rows),'type':{1:'SCALAR',2:'VEC2',3:'VEC3',4:'VEC4'}[width]}
        if width==3 and kind==5126:a.update(min=[min(r[i]for r in rows)for i in range(3)],max=[max(r[i]for r in rows)for i in range(3)])
        doc['accessors'].append(a);return len(doc['accessors'])-1
    tids={};mids={}
    for material in model.materials:
        name=material.base_color_texture
        need(not name or name in textures,f'missing source texture {name}')
        pbr={'metallicFactor':0,'roughnessFactor':1}
        if name:
            if name not in tids:
                t=textures[name];doc['images'].append({'name':name,'bufferView':view(png(t.rgba,t.width,t.height)),'mimeType':'image/png'})
                tids[name]=len(doc['textures']);doc['textures'].append({'source':len(doc['images'])-1,'sampler':0})
            pbr['baseColorTexture']={'index':tids[name]}
        mids[material.name]=len(doc['materials'])
        doc['materials'].append({'name':material.name,'pbrMetallicRoughness':pbr,'doubleSided':True,
           'alphaMode':'BLEND','extensions':{'KHR_materials_unlit':{}},
           'extras':{'sourceTextureSlots':[s.name for s in material.textures], 'state':'review approximation'}})
    primitives=[]
    for sub in model.submeshes:
        need(sub.material in mids,'submesh material missing')
        need(all(0<=i<len(sub.positions)for tri in sub.triangles for i in tri),'index out of bounds')
        source_material=next(x for x in model.materials if x.name==sub.material)
        need(not source_material.base_color_texture or sub.uv0,'textured geometry lacks source UV0')
        attrs={'POSITION':attr(sub.positions,3)}
        for key,values,width in [('NORMAL',sub.normals,3),('TEXCOORD_0',sub.uv0,2),('TEXCOORD_1',sub.uv1,2),('TEXCOORD_2',sub.uv2,2),('COLOR_0',sub.colors,4)]:
            if values:
                need(len(values)==len(sub.positions),'attribute length mismatch')
                attrs[key]=attr(values,width)
        primitives.append({'attributes':attrs,'indices':attr([(i,)for tri in sub.triangles for i in tri],1,5125),'material':mids[sub.material],'mode':4})
    doc['meshes'].append({'name':model.name,'primitives':primitives});doc['nodes'].append({'name':model.name,'mesh':0});doc['scenes'][0]['nodes']=[0]
    raw.extend(b'\0'*((-len(raw))%4));doc['buffers'][0]['byteLength']=len(raw)
    js=json.dumps(doc,separators=(',',':')).encode();js+=b' '*((-len(js))%4)
    return struct.pack('<4sII',b'glTF',2,28+len(js)+len(raw))+struct.pack('<I4s',len(js),b'JSON')+js+struct.pack('<I4s',len(raw),b'BIN\0')+raw


def export_zone(source, zone, output, decoder_path):
    need(zone in source.zones,'unknown zone')
    out=Path(output).resolve();need(not out.exists() or not any(out.iterdir()),'output must be new/empty')
    # This tool intentionally exports raw source; keep it outside the mod checkout.
    repo=Path(__file__).resolve().parents[1]
    need(not out.is_relative_to(repo),'raw source output must be outside the mod checkout')
    load,load_textures,png=decoder(decoder_path)
    decoder_root=Path(decoder_path).resolve()
    decoder_digest=hashlib.sha256()
    for file in sorted((decoder_root/'ctr').rglob('*.py')):
        decoder_digest.update(file.relative_to(decoder_root).as_posix().encode()+b'\0'+file.read_bytes())
    link=source.zones[zone];area=mini(source.archives['areas'].single(link['area']),'AD')
    need(len(area)==12,'expected twelve-part area container')
    banks={};texture_sources={}
    for slot in [1,11]:
        banks[slot]={};texture_sources[slot]={}
        if not area[slot].startswith(b'BCH\0'):continue
        for t in load_textures(area[slot]):
            need(t.name not in banks[slot],'duplicate texture within one area bank')
            banks[slot][t.name]=t
            texture_sources[slot][t.name]={'rgbaSha256':sha(t.rgba),'width':t.width,'height':t.height}
    # Slot 1 supplies separately instanced BM objects; slot 11 supplies GR.
    # Same names may have different pixels in these two scopes. Never merge.
    textures=banks[11]
    out.mkdir(parents=True,exist_ok=True)
    report={'schema':1,'zone':zone,**link,'sourceArchiveHashes':source.hashes,'graphics':[],
            'decoder':'sxrmss/n3ds_importer (external GPL-3.0)',
            'decoderCtrPythonSha256':decoder_digest.hexdigest(),
            'adapter':'Version-aware BCH material table; 3DS little-endian ETC color words converted to decoder network order',
            'textureBanksByAreaSlot':texture_sources,
            'limitations':['Review intermediates only; no native GBA placements enabled.',
            'Base texture / vertex colors only; PICA TEV, source alpha/culling/sampler state and animation need independent review.',
            'Chunk coordinates retained; matrix placement, area object instances and source collision are not baked into GLB.']}
    for slot in [1,11]:(out/f'area-{link["area"]:04d}-{slot:02d}.bch').write_bytes(area[slot])
    for index in sorted(set(source.matrices[link['matrix']]['graphics'])-{65535}):
        chunks=mini(source.archives['graphics'].single(index),'GR')
        need(len(chunks)==7 and chunks[1].startswith(b'BCH\0'),'unexpected map graphics record')
        folder=out/f'gr-{index:04d}';folder.mkdir()
        for slot,blob in enumerate(chunks):
            suffix='bch' if blob[:4]==b'BCH\0' else 'bin'
            (folder/f'{slot:03d}.{suffix}').write_bytes(blob)
        item={'index':index,'geometrySha256':sha(chunks[1]),'models':[]}
        for ordinal,model in enumerate(load(chunks[1])):
            data=glb(model,textures,png);name=f'model-{ordinal:02d}.glb';(folder/name).write_bytes(data)
            item['models'].append({'name':model.name,'file':name,'sha256':sha(data),
               'triangles':sum(len(s.triangles)for s in model.submeshes),'submeshes':len(model.submeshes)})
        report['graphics'].append(item)
    (out/'provenance.json').write_text(json.dumps(report,indent=2)+'\n')
    return report


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('romfs',type=Path)
    s=p.add_subparsers(dest='command',required=True)
    i=s.add_parser('inventory');i.add_argument('--output',type=Path,required=True)
    z=s.add_parser('zone');z.add_argument('index',type=int);z.add_argument('--output',type=Path,required=True);z.add_argument('--decoder',type=Path,required=True)
    a=p.parse_args();source=Source(a.romfs)
    if a.command=='inventory':
        a.output.write_text(json.dumps(source.report(),indent=2)+'\n');print('zones',len(source.zones),'matrices',len(source.matrices))
    else:
        r=export_zone(source,a.index,a.output,a.decoder);print('zone',a.index,'area',r['area'],'graphics',len(r['graphics']))

if __name__=='__main__':
    try:main()
    except (SourceError,OSError) as e:sys.exit(str(e))
