from pathlib import Path
import os
import hashlib
import json
import struct
from bs4 import BeautifulSoup
from urllib.parse import urlsplit,unquote
base=os.environ.get('BASE_PATH','').rstrip('/')
root=Path(__file__).parent/'dist';bad=[];count=0
for f in root.rglob('*.html'):
 soup=BeautifulSoup(f.read_text(),'html.parser');count+=1
 for tag,attr in [('a','href'),('img','src'),('link','href'),('script','src')]:
  for el in soup.find_all(tag):
   u=el.get(attr,'');parts=urlsplit(u)
   if parts.scheme or parts.netloc or not u:continue
   if u.startswith('#'):
    if not soup.find(id=unquote(u[1:])):bad.append((str(f.relative_to(root)),u))
    continue
   path=parts.path
   if base and path.startswith(base+'/'): path=path[len(base):]
   p=root/path.lstrip('/') if u.startswith('/') else f.parent/path
   if p.is_dir():p=p/'index.html'
   if not p.exists():bad.append((str(f.relative_to(root)),u))
print('Checked',count,'pages;',len(bad),'broken local links/assets')
for item in bad[:50]:print(item)

# Every displayed screenshot must be the exact native capture in provenance.
evidence=json.loads((Path(__file__).parent/'content/extension/screenshots.json').read_text())
features=json.loads((Path(__file__).parent/'content/extension/features.json').read_text())
for name in {name for feature in features for name,_ in feature['images']}:
 assert name in evidence['images'],f'Missing capture provenance: {name}'
 capture=(root/'assets'/name).read_bytes()
 width,height=struct.unpack('>II',capture[16:24]) if capture[:8]==b'\x89PNG\r\n\x1a\n' else (0,0)
 expected=evidence['images'][name]
 assert (width,height)==(expected['width'],expected['height']),f'Capture dimensions changed: {name}'
 assert hashlib.sha256(capture).hexdigest()==expected['sha256'],f'Capture bytes changed: {name}'
print('Checked',len(evidence['images']),'native capture checksums and dimensions')

# Course code and download must stay identical to the authoritative R source.
import re
source=(Path(__file__).parent/'content/training/dataraft_training.R').read_text()
assert (root/'downloads/dataraft_training.R').read_text()==source
parts=re.split(r'^# (.+?) ----\s*$',source,flags=re.M)
expected={}
for i in range(1,len(parts),2):
 match=re.match(r'([HEV]\d{2})[a-z]?\s',parts[i])
 if match:
  executable='\n'.join(s for s in parts[i+1].splitlines() if s.strip() and not s.startswith('#'))
  expected.setdefault(match[1].lower(),[]).append(executable)
for key,blocks in expected.items():
 page=BeautifulSoup((root/'training'/key/'index.html').read_text(),'html.parser')
 actual=['\n'.join(s for s in c.get_text().splitlines() if s.strip()) for c in page.select('main pre code')]
 assert actual==[b for b in blocks if b],f'Course code mismatch: {key}'
 assert len(page.select('details.training-solution'))==len(blocks),f'Missing solution: {key}'
 assert page.html.get('lang')=='en'
print('Checked',len(expected),'course modules: code, solutions, language and script download match')


# Keep the generated reference and teaching code on the current public API.
retired = ('dr_trial', 'dr_add_product', 'dr_update_product', 'dr_remove_product',
           'dr_extract_product', 'dr_replace_sources', 'dr_update_contract',
           'dr_remove_contract', 'dr_extract_contract', 'dr_update_source',
           'dr_remove_source', 'dr_extract_source')
upstream = Path(__file__).parent/'content/upstream'
assert not (upstream/'dataraft.catalog').exists()
assert not (root/'packages/dataraft.catalog').exists()
for package in upstream.iterdir():
 for topic in (package/'man').glob('*.Rd'):
  text = topic.read_text()
  for name in retired:
   assert '\\alias{' + name + '}' not in text, f'Retired reference: {topic}: {name}'
for page in root.rglob('index.html'):
 if '/news/' in str(page):
  continue
 soup = BeautifulSoup(page.read_text(), 'html.parser')
 for block in soup.select('main pre code'):
  text = block.get_text()
  for name in retired:
   assert not re.search(r'\b' + name + r'\s*\(', text), f'Retired teaching call: {page}: {name}'
print('Checked current API references and executable teaching examples')

raise SystemExit(bool(bad))
