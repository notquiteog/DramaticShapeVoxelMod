"""Authored rear/underside surfaces for the two source top-down buildings.

All coordinates follow the original opening-edge vertices, in original units.
No front door, source attachment, footprint or original textured face is removed.
UV islands are sampled from their existing wall/roof materials.
"""
import math

def hull(points):
 points=sorted(set((p[0],p[2]) for p in points))
 def cross(a,b,c):return (b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0])
 low=[]
 for p in points:
  while len(low)>=2 and cross(low[-2],low[-1],p)<=1e-8:low.pop()
  low.append(p)
 high=[]
 for p in reversed(points):
  while len(high)>=2 and cross(high[-2],high[-1],p)<=1e-8:high.pop()
  high.append(p)
 return low[:-1]+high[:-1]

def close_building(model,parts):
 if model not in ('oras_pokemon_center','hgss_oaks_lab'):return [],{}
 authored=[]
 def part(name,material,texture):
  p={'name':'authored_'+name,'material':material,'texture':texture,'diffuse':[1.,1.,1.],'opacity':1.,'vertices':[],'wrapS':'repeat','wrapT':'repeat','authored':True};authored.append(p);return p
 def poly(p,points,uv=None):
  uv=uv or[(.5,.5)]*len(points)
  for i in range(1,len(points)-1):p['vertices'].extend([list(points[j])+list(uv[j])+[1.] for j in (0,i,i+1)])
 def quad(p,a,b,c,d,uv=None):poly(p,[a,b,c,d],uv)
 if model=='hgss_oaks_lab':
  # Native brick side-wall ends are x+-52,z-28,y8..56.
  wall=part('rear_brick','mt_okl07','mt_okl07.png')
  quad(wall,(-52,8,-28),(52,8,-28),(52,56,-28),(-52,56,-28),[(.0703125,3),(2.62388393,3),(2.62388393,0),(.0703125,0)])
  base=part('rear_foundation','mt_okl04','mt_okl04.png')
  quad(base,(-52,2,-28),(52,2,-28),(52,8,-28),(-52,8,-28),[(.84375,.59375),(.84375,.59375),(.84375,.21875),(.84375,.21875)])
  roof=part('rear_roof_trim','lambert1',None);roof['diffuse']=[.3764706]*3
  # Flat outer fascia, its two native bevels, an inner lip and solid top.
  quad(roof,(-52,52,-32),(52,52,-32),(52,64,-32),(-52,64,-32))
  for side in (-1,1):
   quad(roof,(side*52,52,-32),(side*54,52,-30),(side*54,64,-30),(side*52,64,-32))
  quad(roof,(-48,58,-26),(48,58,-26),(48,64,-26),(-48,64,-26))
  quad(roof,(-52,64,-32),(52,64,-32),(48,64,-26),(-48,64,-26))
  quad(roof,(-52,52,-32),(52,52,-32),(52,52,-28),(-52,52,-28))
  # Corner returns meet the original side trim/inner roof boundary.
  for side in (-1,1):
   poly(roof,[(side*52,64,-32),(side*54,64,-30),(side*48,64,-26)])
   quad(roof,(side*48,58,-26),(side*48,64,-26),(side*54,64,-30),(side*54,58,-30))
   quad(roof,(side*52,52,-28),(side*52,52,-32),(side*54,52,-30),(side*54,52,-28))
  structural=[v for p in parts if p['material']!='h_kage' for v in p['vertices']]
  bottom=1.;top=2.;ground=hull([v for v in structural if abs(v[1]-top)<1e-5])
  underside=part('closed_underside','lambert1',None);underside['diffuse']=[.3764706]*3
  door=[0.,2.,23.]
 else:
  x0,x1=-48.922852,45.723145;floor=-44.504868;plinth=-35.684155;wall_top=2.118845;back=-55.449329
  wall=part('rear_wall','pokecen_01','pokecen_01.png')
  for i in range(4):
   a=x0+(x1-x0)*i/4;b=x0+(x1-x0)*(i+1)/4
   quad(wall,(a,plinth,back),(b,plinth,back),(b,wall_top,back),(a,wall_top,back),[(.00391,.007812),(.00391,.242187),(.38281,.242187),(.38281,.007812)])
  base=part('rear_plinth','pokecen_01','pokecen_01.png')
  quad(base,(x0,floor,back),(x1,floor,back),(x1,plinth,back),(x0,plinth,back),[(.738,.242187),(.738,.242187),(.738,.148437),(.738,.148437)])
  roof=part('rear_roof_trim','pokecen_01','pokecen_01.png')
  # Cross section follows the native cut edges: lower return, pitched fascia,
  # narrow outer lip, roof top and inner return. Four texture panel repeats.
  xl,xr=-46.40265,43.20295
  for i in range(4):
   a=xl+(xr-xl)*i/4;b=xl+(xr-xl)*(i+1)/4
   t=i/4;u=(i+1)/4;ba=x0+(x1-x0)*t;bb=x0+(x1-x0)*u
   quad(roof,(ba,wall_top,back),(bb,wall_top,back),(b,9.049,-57.969524),(a,9.049,-57.969524),[(.1914,.73),(.3164,.73),(.3164,.59),(.1914,.59)])
   quad(roof,(a,9.049,-57.969524),(b,9.049,-57.969524),(b,11.907745,-57.969524),(a,11.907745,-57.969524),[(.1914,.60),(.3164,.60),(.3164,.56),(.1914,.56)])
   quad(roof,(a,11.907745,-57.969524),(b,11.907745,-57.969524),(b,9.67945,-52.92913),(a,9.67945,-52.92913),[(.1914,.79),(.3164,.79),(.3164,.99),(.1914,.99)])
   quad(roof,(a,wall_top,-52.92913),(b,wall_top,-52.92913),(b,9.67945,-52.92913),(a,9.67945,-52.92913))
   quad(roof,(ba,wall_top,back),(bb,wall_top,back),(b,wall_top,-52.92913),(a,wall_top,-52.92913))
  for x,bx in ((xl,x0),(xr,x1)):
   poly(roof,[(bx,wall_top,back),(x,9.049,-57.969524),(x,11.907745,-57.969524),(x,9.67945,-52.92913),(x,wall_top,-52.92913)])
  # Raised native skylight's open rear arch: use the original roof's gray
  # inset color, without adding a sign, window or attachment to its rear.
  cap=part('skylight_rear_cap','pokecen_01','pokecen_01.png')
  arch=[(-21.76195,24.801,-42.848),(-18.773,29.792,-42.848),(-14.077,33.363,-42.848),(-8.16,35.655,-42.848),(-1.599854,36.444641,-42.848),(4.96,35.655,-42.848),(10.877,33.363,-42.848),(15.573,29.792,-42.848),(18.56225,24.801,-42.848)]
  poly(cap,arch,[(.738,.24)]*len(arch))
  structural=[v for p in parts for v in p['vertices']];top=floor;bottom=floor-.05
  ground=hull([v for v in structural if abs(v[1]-top)<.001])
  underside=part('closed_underside','pokecen_01','pokecen_01.png')
  door=[-1.5998535,floor,31.67667]
 # A thin closed foundation under the source ground faces prevents a
 # coplanar floor/underside flicker. Original doorway/threshold remains open.
 poly(underside,[(x,bottom,z) for x,z in reversed(ground)],[(.738,.24)]*len(ground))
 for i,a in enumerate(ground):
  b=ground[(i+1)%len(ground)];quad(underside,(a[0],bottom,a[1]),(b[0],bottom,b[1]),(b[0],top,b[1]),(a[0],top,a[1]))
 return authored,{'door':door,'description':'Authored rear wall/roof return/skylight cap where present, plus closed foundation. Original front portal remains open. Existing source wall/roof UV islands only.','parts':[p['name'] for p in authored],'triangles':sum(len(p['vertices'])//3 for p in authored),'foundationBottom':bottom,'foundationTop':top}
