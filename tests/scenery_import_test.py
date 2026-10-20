import copy, hashlib, os, sys, tempfile, unittest, zipfile
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from import_scenery_models import CATALOG, convert, dae_static, materials, normalize, obj
from scenery_closures import close_building

class StaticImporterTest(unittest.TestCase):
 def test_obj_negative_indices_material_groups_and_v(self):
  raw=b'v 0 0 0\nv 2 0 0\nv 2 1 0\nv 0 1 0\nvt 0 0\nvt 1 0\nvt 1 1\nvt 0 1\ng wall\nusemtl a\nf -4/-4 -3/-3 -2/-2 -1/-1\n'
  p,_=obj(raw,{'a':{'diffuse':[1,1,1],'opacity':1,'texture':'wall.png'}},{'wall.png':'wall.png'})
  self.assertEqual(len(p[0]['vertices']),6);self.assertEqual(p[0]['vertices'][0],[0,0,0,0,1,1]);self.assertEqual(p[0]['name'],'wall')
 def test_invalid_textured_uv_and_missing_texture_fail(self):
  raw=b'v 0 0 0\nv 1 0 0\nv 0 1 0\nvt NaN 0\nusemtl a\nf 1/1 2/1 3/1\n'
  mat={'a':{'diffuse':[1,1,1],'opacity':1,'texture':'a.png'}}
  with self.assertRaises(ValueError):obj(raw,mat,{'a.png':'a.png'})
  with self.assertRaises(ValueError):obj(raw,mat,{})
 def test_concave_face_requires_source_triangulation(self):
  raw=b'v 0 0 0\nv 2 0 0\nv .4 .4 0\nv 0 2 0\nusemtl a\nf 1 2 3 4\n'
  with self.assertRaises(ValueError):obj(raw,{'a':{'diffuse':[1,1,1],'opacity':1}}, {})

@unittest.skipUnless(os.getenv('SCENERY_MODEL_ARCHIVES'),'external original archives not supplied')
class SuppliedArchiveTest(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.root=Path(os.environ['SCENERY_MODEL_ARCHIVES']);cls.tmp=tempfile.TemporaryDirectory();out=Path(cls.tmp.name);(out/'lib').mkdir();cls.models,cls.reports=convert(cls.root,out);cls.out=out
 @classmethod
 def tearDownClass(cls):cls.tmp.cleanup()
 def test_source_counts_original_textures_and_authored_parts(self):
  for name,r in CATALOG.items():
   with zipfile.ZipFile(self.root/(str(r['asset'])+'.zip'))as z:
    if r['file'].endswith('.obj'):parts,fixes=obj(z.read(r['file']),materials(z.read(r['mtl'])),{Path(n).name:n for n in z.namelist()},r.get('bindings'),r.get('solid_fallbacks',()))
    else:parts=dae_static(z.read(r['file']));fixes=[]
    count=sum(len(p['vertices'])//3 for p in parts);self.assertEqual(count,{'oras_pokemon_center':1045,'hgss_oaks_lab':230,'bw2_sign01':28}[name])
    for image,meta in self.reports[name]['textures'].items():
     raw=z.read(next(n for n in z.namelist()if Path(n).name==image));self.assertEqual(hashlib.sha256(raw).hexdigest(),meta['sha256']);self.assertEqual((self.out/f'assets/scenery/catalog/{name}/{image}').read_bytes(),raw)
    # Import normalization and additions retain every original triangle/UV.
    processed=self.models[name]['parts']
    for i,source in enumerate(parts):
     decoded=[processed[i]['vertices'][j-1]for j in processed[i]['indices']]
     self.assertEqual([v[3:]for v in decoded],[v[3:]for v in source['vertices']])
 def test_rear_planes_covered_and_closed_bottoms(self):
  for name in ['oras_pokemon_center','hgss_oaks_lab']:
   recipe=CATALOG[name]
   with zipfile.ZipFile(self.root/(str(recipe['asset'])+'.zip'))as z:
    parts,_=obj(z.read(recipe['file']),materials(z.read(recipe['mtl'])),{Path(n).name:n for n in z.namelist()},recipe.get('bindings'),recipe.get('solid_fallbacks',()))
   added,meta=close_building(name,parts);self.assertTrue(meta['door']);self.assertTrue(meta['triangles']>0)
   underside=next(p for p in added if p['name']=='authored_closed_underside');self.assertGreater(len(underside['vertices']),6)
   bounds=self.reports[name]['originalSourceBounds']
   for p in added:
    for v in p['vertices']:
     self.assertGreaterEqual(v[0],bounds[0]-1e-5);self.assertLessEqual(v[0],bounds[3]+1e-5);self.assertGreaterEqual(v[2],bounds[2]-1e-5);self.assertLessEqual(v[2],bounds[5]+1e-5)
   wall=next(p for p in added if p['name'] in ['authored_rear_wall','authored_rear_brick'])
   # Every interior point on each authored wall rectangle lies on a triangle;
   # joins of its tiled UV islands have no unfilled geometric seam.
   verts=wall['vertices'];xs=[v[0]for v in verts];ys=[v[1]for v in verts]
   def inside(p,t):
    a,b,c=t;cross=lambda u,v,w:(v[0]-u[0])*(w[1]-u[1])-(v[1]-u[1])*(w[0]-u[0]);s=[cross(a,b,p),cross(b,c,p),cross(c,a,p)];return min(s)>=-1e-7 or max(s)<=1e-7
   for ix in range(1,20):
    for iy in range(1,20):
     point=(min(xs)+(max(xs)-min(xs))*ix/20,min(ys)+(max(ys)-min(ys))*iy/20)
     self.assertTrue(any(inside(point,t)for t in [verts[i:i+3]for i in range(0,len(verts),3)]))
 def test_portal_anchor_and_sign_surface(self):
  for name in ['oras_pokemon_center','hgss_oaks_lab']:self.assertIn('door',self.models[name]['anchors'])
  s=self.models['bw2_sign01']['surfaces']['message'];p=self.models['bw2_sign01']['parts'][s['part']-1]
  selected=[p['vertices'][p['indices'][j]-1]for t in s['triangles']for j in range(t*3-3,t*3)]
  self.assertEqual(len(selected),6);self.assertAlmostEqual(max(v[2]for v in selected)-min(v[2]for v in selected),0);self.assertEqual(s['normal'],[0,0,1])

if __name__=='__main__':unittest.main()
