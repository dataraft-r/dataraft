from pathlib import Path
import os
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

raise SystemExit(bool(bad))
