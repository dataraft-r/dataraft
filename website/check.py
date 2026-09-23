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
raise SystemExit(bool(bad))
