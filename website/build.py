from pathlib import Path
import re,json,html,markdown,shutil,os
from bs4 import BeautifulSoup
ROOT=Path(__file__).parent; OUT=ROOT/'dist'; UP=ROOT/'content/upstream'
shutil.rmtree(OUT, ignore_errors=True)
OUT.mkdir(exist_ok=True)
shutil.copytree(ROOT/'assets',OUT/'assets',dirs_exist_ok=True)
sha=json.loads((ROOT/'content/sources.json').read_text()); esc=html.escape
packages={
'dataraft':('The family, together','Start here','A focused entry point to checked data products. The metapackage exposes 17 product verbs and dr_demo(); specialist functions stay in their component namespaces.'),
'dataraft.core':('Define and check','Core','Products, contracts, preparation and quality gates. Start in memory, compose ordinary R transformations, and inspect every execution result.'),
'dataraft.lake':('Retain checked releases','Storage','Publish versioned data with DuckDB or DuckLake. Inspect release history, coordinate publication and recover interrupted operations.'),
'dataraft.adapters':('Connect your tools','Integration','Sources, destinations and metadata publishers for databases, RDS, Parquet, pins, APIs, OpenLineage and OpenMetadata.'),
'dataraft.dbt':('Bring SQL models along','Experimental','Configure dbt projects, run builds and inspect artifacts. Add managed publication when SQL results need DataRaft release governance.'),
'dataraft.metrics':('Keep reporting evidence','Experimental','Define metrics, evaluate checked inputs and retain frozen report evidence. A governed results layer, not a general-purpose semantic modeling engine.'),
'dataraft.ide':('Connect R to your editor','Experimental','The optional R metadata bridge for Positron. Inspect an existing workspace or lake without transferring data cells to the extension.'),}
pages={}; aliases={}; refs={}; current_pkg='dataraft'
def group(s,i):
 assert s[i]=='{'
 depth=1;j=i+1
 while j<len(s) and depth:
  if s[j]=='{' and (j==0 or s[j-1]!='\\'):depth+=1
  elif s[j]=='}' and s[j-1]!='\\':depth-=1
  j+=1
 return s[i+1:j-1],j

def fields(s):
 result=[];i=0
 while i<len(s):
  m=re.search(r'\\([A-Za-z][A-Za-z0-9]*)',s[i:])
  if not m:break
  a=i+m.start();i+=m.end();name=m[1];opt=''
  if i<len(s) and s[i]=='[':
   k=s.find(']',i);opt=s[i+1:k];i=k+1
  if i<len(s) and s[i]=='{':
   val,i=group(s,i);second=None
   if name in ('item','section','href','ifelse') and i<len(s) and s[i]=='{':second,i=group(s,i)
   result.append((name,val,second,opt))
 return result
for pkg in packages:
 refs[pkg]=[]
 for p in sorted((UP/pkg/'man').glob('*.Rd')):
  text=p.read_text();ff=fields(text);d={k:v for k,v,_,_ in ff}
  slug=p.stem;url=f'/packages/{pkg}/reference/{slug}/'
  for k,v,_,_ in ff:
   if k=='alias':aliases[(pkg,v)]=url
  refs[pkg].append((p,ff,d,url))

def rd(s,pkg):
 out='';i=0
 while i<len(s):
  if s[i]=='\\':
   m=re.match(r'\\([A-Za-z][A-Za-z0-9]*)',s[i:])
   if m:
    name=m[1];i+=len(m[0]);opt=''
    if i<len(s) and s[i]=='[':
     end=s.find(']',i);opt=s[i+1:end];i=end+1
    vals=[]
    while i<len(s) and s[i]=='{' and len(vals)<(2 if name in ('href','item','ifelse') else 1):
     v,i=group(s,i);vals.append(v)
    v=vals[0] if vals else '';inner=rd(v,pkg)
    if name=='link':
     target=opt.lstrip('=') or v;other=pkg
     if ':' in target:other,target=target.split(':',1)
     url=aliases.get((other,target)) or aliases.get((pkg,v))
     out+=f'<a href="{url}">{inner}</a>' if url else inner
    elif name in ('code','verb','kbd','command','file','env','samp'):out+='<code>'+inner+'</code>'
    elif name in ('strong','bold'):out+='<strong>'+inner+'</strong>'
    elif name in ('emph','var','dfn'):out+='<em>'+inner+'</em>'
    elif name=='href':out+=f'<a href="{esc(v,quote=True)}">{rd(vals[1],pkg) if len(vals)>1 else inner}</a>'
    elif name=='url':out+=f'<a href="{esc(v,quote=True)}">{inner}</a>'
    elif name=='item':out+=f'<dt>{inner}</dt><dd>{rd(vals[1],pkg)}</dd>' if len(vals)>1 else '<br>• '+inner
    elif name=='describe':out+='<dl>'+inner+'</dl>'
    elif name in ('itemize','enumerate'):out+='<div class="rd-list">'+inner+'</div>'
    elif name=='preformatted':out+='<pre><code>'+esc(v)+'</code></pre>'
    elif name=='dontrun':out+=inner
    elif name=='R':out+='R'
    elif name=='dots':out+='…'
    else:out+=inner
    continue
   if i+1<len(s):out+=esc(s[i+1]);i+=2;continue
  out+=esc(s[i]);i+=1
 return out.replace('\n\n','<br><br>')

def md(text,pkg='dataraft',source='README.md'):
 text=re.sub(r'^---\n.*?\n---\n','',text,flags=re.S)
 text=re.sub(r'```\{r[^\n]*include\s*=\s*FALSE[^\n]*\}\n.*?```','',text,flags=re.S)
 text=re.sub(r'```\{r[^\n]*\}','```r',text)
 text=text.replace('—',',')
 soup=BeautifulSoup(markdown.markdown(text,extensions=['fenced_code','tables','toc','sane_lists']),'html.parser')
 for a in soup.find_all('a',href=True):
  href=a['href']
  if href.startswith('#'):continue
  if not re.match(r'^(https?:|mailto:|/)',href):
   a['href']=f'https://github.com/dataraft-r/{pkg}/blob/{sha[pkg]}/'+str(Path(source).parent/href)
 for im in soup.find_all('img'):
  if not im.get('src','').startswith('http'):im['src']=f'https://raw.githubusercontent.com/dataraft-r/{pkg}/{sha[pkg]}/'+str(Path(source).parent/im['src'])
 return str(soup)

def code(s):return '<pre><code class="language-r">'+esc(s.strip())+'</code></pre>'
def add(url,title,body,section='Learn',desc='',source=None):pages[url]=dict(title=title,body=body,section=section,desc=desc,source=source)
def cards(items):return '<div class="cards">'+''.join(f'<a class="card" href="{url}"><span class="eyebrow">{label}</span><h3>{title}</h3><p>{body}</p><span class="card-end">Explore ↗</span></a>' for url,label,title,body in items)+'</div>'

intro='''library(dataraft)

orders <- dr_product("orders") |>
  dr_add_contract(c(id = "integer", amount = "numeric")) |>
  dr_add_quality(~ amount >= 0)

result <- dr_run(orders,
  data = data.frame(id = 1:3, amount = c(25, 75, 50)),
  write = FALSE
)

dr_collect(result)'''
home='''<section class="hero"><div><span class="eyebrow">THE DATA PRODUCT FRAMEWORK FOR R</span><h1>Good data.<br>By definition.</h1><p class="lead">Turn repeated deliveries into reusable data products. Define the contract, check the quality and keep the evidence.</p><div class="actions"><a class="button" href="/start/">Start with a data product <span>↗</span></a><a class="text-link" href="/packages/">Explore the packages</a></div><p class="fine">R first · Composable · Open source</p></div><div class="hero-code"><div class="code-title"><span>your-first-product.R</span><span>R</span></div>'''+code(intro)+'''<div class="code-result"><span>✓</span> Checked output, ready to inspect.</div></div></section><section class="principles"><div><span>01 / DEFINE</span><h3>Make expectations explicit.</h3><p>Column types, keys and business rules live with the product.</p></div><div><span>02 / CHECK</span><h3>Catch the bad delivery.</h3><p>Run the same preparation and checks before writing a target.</p></div><div><span>03 / RETAIN</span><h3>Know what went into it.</h3><p>Pin releases and retain evidence for repeatable reporting.</p></div></section><section class="section"><div class="section-heading"><div><span class="eyebrow">A CLEAR PATH IN</span><h2>Learn it one product at a time.</h2></div><p>Start in memory. Add storage and integrations when your workflow needs them.</p></div>'''+cards([
('/start/','GET STARTED / 5 CHAPTERS','From your first check to a saved delivery','A guided path through products, contracts, quality and versioned RDS output.'),('/learn/','GO FURTHER','Build a real reporting workflow','Related tables, insurance deliveries, open contracts and adapter authoring.'),('/extension/','IN YOUR EDITOR','See your products in Positron','Inspect metadata, follow lineage and work with contract YAML.')])+'''</section><section class="install-band"><div><span class="eyebrow">START SMALL</span><h2>One family. Your choice of tools.</h2><p>Use the metapackage for the common API, or install only the component you need.</p></div>'''+code('install.packages("pak")\npak::pak("dataraft-r/dataraft")')+'''</section><p class="notice">Development software: APIs and integrations are experimental. Read the installation and compatibility guidance before pinning a production environment.</p>'''
add('/','DataRaft',home,'Home','Checked data products, contracts and reproducible reporting in R.')
start_titles=['Install and orient','Define a product','Check a delivery','Save and pin a version','Put it together']
start_bodies=[
'''## Start without a database
You need R 4.2 or newer. The development family is installed from GitHub. There is no stable public release claimed by the current compatibility lock.
```r
install.packages("pak")
pak::pak("dataraft-r/dataraft")
library(dataraft)
demo <- dr_demo()
demo$blocked$status
dr_collect(demo$passed)
```
`dr_demo()` contains one rejected delivery and one corrected delivery. It is a small way to inspect the result model before you configure storage.

## Install only what you need
For in-memory definitions and checks, use `dataraft.core`. RDS persistence uses `dataraft.adapters`. DuckDB, Arrow and dbt are not required for the first in-memory example.
```r
pak::pak("dataraft-r/dataraft.core")
library(dataraft.core)
```
## Understand the objects
A **product** is a reusable definition: identity, sources, preparation, contract, quality checks and destination. A **run result** retains status, check evidence and output. A **release** is an immutable published version on a supported target.

## Pin the family
The umbrella repository's `family-lock.json` records a tested development combination with immutable component commits. Individual GitHub HEAD installs can move independently. Use the [compatibility policy](/learn/compatibility/) when establishing a reproducible environment. Development Remotes use main. Install the component SHAs in that lock when you need the exact tested family. Earlier development interfaces and registry migrations are not supported.
''',
'''## Describe the delivery
A contract makes the schema explicit. Here each row represents one order and `id` is the key.
```r
library(dataraft)
contract <- dr_contract("orders",
  columns = c(id = "integer", amount = "numeric"), key = "id") |>
  dataraft.core::dr_contract_meta(owner = "Analytics", grain = "One order")
orders <- dr_product("orders", contract = contract) |>
  dr_add_quality(dr_quality(~ amount >= 0, action = "block"))
```
## Keep preparation reusable
Attach a recipe when the same preparation should apply to every delivery. Ordinary dplyr verbs and transform functions also fit the product model.
```r
orders <- orders |>
  dataraft.core::dr_add_recipe(
    dataraft.core::dr_recipe() |>
      dataraft.core::dr_step_mutate(amount = round(amount, 2))
  )
```
## Inspect before execution
```r
dataraft.core::dr_plan(orders)
dataraft.core::dr_validate(orders)
```
These inspect the definition and its configuration. They do not establish the quality of a delivery. Without a declared contract, inferred schema checks are labelled `unvalidated`.
''',
'''## Let a bad delivery fail visibly
Continue with `orders` from chapter 2. Supply one negative amount and retain the blocked result instead of throwing an error.
```r
bad_delivery <- data.frame(id = 1:3, amount = c(25, -75, 50))
checked <- dr_run(orders, data = bad_delivery,
  write = FALSE, stop_on_failure = FALSE)
checked$status
# "blocked"
dataraft.core::dr_quality_rows(checked)
dr_quality_report(checked)
```
The rejected row has `id = 2` and `amount = -75`. The product definition stays reusable: fix the delivery, not the rule.
```r
next_delivery <- data.frame(id = 1:3, amount = c(25, 75, 50))
result <- dr_run(orders, data = next_delivery, write = FALSE)
dr_collect(result)
```
## Understand the boundary
`write = FALSE` suppresses framework target, catalog and run-evidence writes, including upstream products. It still reads sources and runs user functions, which can have their own side effects. It does not reserve the checked source for a later run.

Use `action = "warn"` for a non-blocking rule. Quarantine removes rejected rows before writing. Read the function reference before changing thresholds or introducing volatile checks.

## Diagnose a thrown failure
`dr_last_failure()` retrieves retained evidence after an error. `dataraft.core::dr_quality_errors(result)` exposes locally retained exceptions. Exported reports omit raw exception text.
''',
'''## Save a checked snapshot
Continue with `orders` and `next_delivery` from the previous chapters. RDS gives you local versioned releases without a database engine.
```r
folder <- tempfile("dataraft-rds-")
saved <- dr_publish(orders, data = next_delivery,
  to = dataraft.adapters::dr_target_rds(folder))
reference <- saved$outputs$version
```
## Read the exact version
```r
restored <- dataraft.core::dr_read_source(
  dataraft.adapters::dr_source_rds(folder, version = reference)
)
stopifnot(sum(restored$amount) == 150)
```
Keep the version reference with your reporting inputs. Reading “latest” later is a different reproducibility choice from reading the saved version.

## Choose storage deliberately
RDS retains existing versions, coordinates cooperating local writers and renames a completed staging directory into place. It is not a distributed lock service or a transaction across multiple tables. Network filesystems need suitable directory and rename semantics.

For a shared lake, explore [dataraft.lake](/packages/dataraft.lake/). DuckDB and DuckLake have different operational requirements. The generic execution path materializes output for checking, so plan for memory proportional to that output.
```r
# Only remove the temporary tutorial output when you are finished.
unlink(folder, recursive = TRUE)
```
''',
'''## A realistic next step
A monthly insurance report combines customers, policy snapshots, brokers and payments. Contracts protect the individual deliveries; relationship checks protect joins and table grain.

The [insurance walkthrough](/learn/relational-insurance/) uses synthetic data and the package's bundled fixtures. Follow it to check composite keys, avoid duplicate premiums, handle late corrections and compare pinned reporting inputs.

## Choose the right next chapter
| Your next task | Read next |
|---|---|
| Related tables and dm relationships | [Insurance deliveries](/learn/relational-insurance/) |
| Exchange ODCS contracts | [Open contracts](/learn/open-contracts/) |
| Connect external systems | [Integrations](/learn/integrations/) |
| Inspect products in your editor | [Positron and VS Code](/extension/) |
| Implement a custom source or target | [Adapter authoring](/learn/adapter-authoring/) |
| Understand transaction and execution limits | [Guarantees](/learn/guarantees/) |

## Keep responsibilities clear
DataRaft coordinates checked deliveries. `dm` expresses relational structure, dbt develops SQL models, targets schedules pipelines and pointblank supplies standalone validation. Add the integration that serves the use case; none of them is a prerequisite for the first product.
''']
add('/start/','Get started', '<p class="lead">A guided introduction in five chapters. Start in memory and finish with a versioned, checked delivery.</p>'+cards([(f'/start/{i+1}/',f'CHAPTER {i+1:02}',t, ['Install the development family and understand its objects.','Declare schema, keys and a reusable quality gate.','Inspect a blocked result and correct the delivery.','Publish locally and read the same snapshot again.','Move on to related tables and real reporting.'][i]) for i,t in enumerate(start_titles)]),'Get started')
for i,(title,body) in enumerate(zip(start_titles,start_bodies)):
 nav='<div class="chapter-nav">'+(f'<a href="/start/{i}/">← {start_titles[i-1]}</a>' if i else '<a href="/start/">All chapters</a>')+(f'<a href="/start/{i+2}/">{start_titles[i+1]} →</a>' if i<4 else '<a href="/learn/">Continue learning →</a>')+'</div>'
 add(f'/start/{i+1}/',title,md(body)+nav,'Get started',f'Chapter {i+1} of the DataRaft introduction.')

learn=[]
for pkg in packages:
 for file in sorted((UP/pkg/'vignettes').glob('*.Rmd')):
  if file.stem=='get-started':continue
  s=file.read_text();m=re.search(r'^title:\s*["\']?(.*?)["\']?$',s,re.M);title=m[1] if m else file.stem
  # Preserve setup imports required by examples when the hidden setup chunk is removed.
  if re.search(r'```\{r setup[^\n]*\}[^`]*library\(dataraft\)',s):s=re.sub(r'(---\n.*?\n---\n)',r'\1\n```r\nlibrary(dataraft)\n```\n',s,count=1,flags=re.S)
  url=f'/learn/{file.stem}/';add(url,title,md(s,pkg,'vignettes/'+file.name),'Learn',source=(pkg,'vignettes/'+file.name));learn.append((url,pkg,title,'A practical guide from the package documentation.'))
for filename,title in [('FAMILY_COMPATIBILITY.md','Pin a compatible family'),('SECURITY.md','Security and trust boundaries'),('CONTRIBUTING.md','Contribute to DataRaft'),('CHEATSHEET.md','The DataRaft cheatsheet')]:
 slug={'FAMILY_COMPATIBILITY.md':'compatibility','SECURITY.md':'security','CONTRIBUTING.md':'contributing','CHEATSHEET.md':'cheatsheet'}[filename];s=(UP/'dataraft'/filename).read_text();s=re.sub(r'^# .*\n','',s,count=1)
 add('/learn/'+slug+'/',title,md(s),'Learn',source=('dataraft',filename));learn.append(('/learn/'+slug+'/','PROJECT',title,'Project guidance and practical reference.'))
ports=(ROOT/'content/guides/output-ports.md').read_text()
add('/learn/output-ports/','Publish to multiple output ports',md(ports),'Learn',
    'Release evidence, SLA checks and partial output failures.')
learn.append(('/learn/output-ports/','DATA PRODUCTS','Publish to multiple output ports',
              'One checked delivery, multiple targets and explicit partial-failure evidence.'))
add('/learn/','Go further with DataRaft','<p class="lead">Learn by task: model relationships, connect tools, preserve evidence and extend the framework.</p>'+cards(learn),'Learn')
add('/packages/','One family. Clear responsibilities.','<p class="lead">Start with the common product API. Add storage, integrations and editor support independently.</p>'+cards([(f'/packages/{p}/',tag,p,desc) for p,(_,tag,desc) in packages.items()]),'Packages')
entry={'dataraft':['dr_product','dr_contract','dr_run','dr_collect','dr_demo'],'dataraft.core':['dr_product','dr_add_source','dr_recipe','dr_validate','dr_quality_rows'],'dataraft.lake':['dr_open_lake','dr_target_lake','dr_releases','dr_close_lake'],'dataraft.adapters':['dr_target_rds','dr_source_database','dr_contract_from_odcs','dr_catalog_openmetadata'],'dataraft.dbt':['dr_dbt_project','dr_dbt_build'],'dataraft.metrics':['dr_metric','dr_measure','dr_report_verify'],'dataraft.ide':['ide_context','ide_request']}
for pkg,(title,tag,desc) in packages.items():
 ver=re.search(r'^Version: (.*)$',(UP/pkg/'DESCRIPTION').read_text(),re.M)[1]
 body=f'<p class="lead">{desc}</p><div class="meta-row"><span>{tag}</span><span>Version {ver}</span><a href="https://github.com/dataraft-r/{pkg}">GitHub ↗</a></div><h2>Install</h2>'+code(f'pak::pak("dataraft-r/{pkg}")')
 if pkg=='dataraft':body+='<h2>A small public surface</h2><p>The metapackage exposes the common product verbs. Use component namespaces for specialist APIs. Begin with the five-chapter tutorial, then use the reference for exact arguments and behavior.</p>'+code(intro)
 body+='<h2>Start with these functions</h2><div class="function-list">'
 for name in entry[pkg]:
  url=aliases.get((pkg,name));body+=f'<a href="{url}"><code>{name}()</code><span>Reference →</span></a>' if url else ''
 body+='</div><h2>Documentation</h2>'+cards([(f'/packages/{pkg}/reference/','API',f'{len(refs[pkg])} reference topics','Usage, arguments, return values and examples from the package source.'),('/start/','GUIDED PATH','Get started','Define, check and publish your first product.')])
 if pkg=='dataraft.ide':body+=cards([('/extension/','EDITOR','Positron and VS Code','Installation, screenshots, supported commands and limits.')])
 if (UP/pkg/'NEWS.md').exists():
  add(f'/packages/{pkg}/news/',f'{pkg} changelog',md((UP/pkg/'NEWS.md').read_text(),pkg,'NEWS.md'),'Packages',source=(pkg,'NEWS.md'));body+=f'<p><a href="/packages/{pkg}/news/">Read the changelog →</a></p>'
 add(f'/packages/{pkg}/',pkg,body,'Packages',desc,source=(pkg,'DESCRIPTION'))
 refbody='<p class="lead">Function signatures, arguments and examples, drawn directly from the documented package source.</p><div class="function-list">'
 for p,ff,d,url in refs[pkg]:
  title=d.get('title',p.stem);refbody+=f'<a href="{url}"><code>{p.stem}</code><span>{esc(re.sub(r"[{}\\\\]", "", title))}</span></a>'
  content=''
  for key in ['description','usage','arguments','value','details','section','examples','seealso','note','references','author','format']:
   for k,v,v2,opt in ff:
    if k!=key:continue
    if k=='description':content+='<div class="lead reference-description">'+rd(v,pkg)+'</div>';continue
    heading=v if k=='section' else {'value':'Value','seealso':'See also','usage':'Usage','arguments':'Arguments','examples':'Examples'}.get(k,k.capitalize())
    val=v2 if k=='section' else v
    content+='<h2>'+esc(heading)+'</h2>'
    if k in ('usage','examples'):content+=code(val.replace('\\dontrun{','# Not run: {').replace('\\donttest{','# Example: {'))
    elif k=='arguments':content+='<dl>'+rd(val,pkg)+'</dl>'
    else:content+='<div>'+rd(val,pkg)+'</div>'
  add(url,p.stem+'()',content,'Reference',re.sub(r'[{}\\]','',title),source=(pkg,'man/'+p.name))
 refbody+='</div>';add(f'/packages/{pkg}/reference/',pkg+' reference',refbody,'Reference')
add('/reference/','Function reference','<p class="lead">Browse the complete documented API by package. Begin with the metapackage for the common verbs.</p>'+cards([(f'/packages/{p}/reference/',f'{len(refs[p])} TOPICS',p,d) for p,(_,_,d) in packages.items()]),'Reference')
features=json.loads((ROOT/'content/extension/features.json').read_text())
evidence=json.loads((ROOT/'content/extension/screenshots.json').read_text())
gallery=[]
for feature in features:
 url='/extension/'+feature['slug']+'/'
 body='<p class="lead">'+esc(feature['summary'])+'</p><div class="meta-row"><span>'+esc(feature['host'])+'</span></div><p class="feature-command"><strong>Command or action</strong><br>'+esc(feature['command'])+'</p>'
 for filename,caption in feature['images']:
  dimensions=evidence['images'][filename]
  body+=f'<figure class="screenshot feature-screenshot"><a href="/assets/{filename}" target="_blank" rel="noopener"><img src="/assets/{filename}" width="{dimensions["width"]}" height="{dimensions["height"]}" alt="{esc(caption,quote=True)}" loading="lazy"></a><figcaption>{esc(caption)} <a href="/assets/{filename}" target="_blank" rel="noopener">Open full-resolution screenshot ↗</a></figcaption></figure>'
 body+=md(feature['body'],'dataraft-positron')
 body+='<div class="source-note">Original capture from the native Positron extension host, using synthetic data. Extension implementation: <code>'+evidence['extension_commit'][:7]+'</code>. Screenshot automation: <code>'+evidence['capture_commit'][:7]+'</code>. <a href="'+evidence['run_url']+'">Successful native capture run ↗</a></div>'
 index=features.index(feature)
 body+='<div class="chapter-nav"><a href="/extension/">← All extension features</a>'+(f'<a href="/extension/{features[index+1]["slug"]}/">{esc(features[index+1]["title"])} →</a>' if index+1<len(features) else '<a href="/extension/reference/">Installation and reference →</a>')+'</div>'
 add(url,feature['title'],body,'Extension',feature['summary'])
 filename=feature['images'][0][0]
 gallery.append(f'<a class="feature-card" href="{url}"><img src="/assets/{filename}" width="1600" height="1000" alt="" loading="lazy"><div><span class="eyebrow">{esc(feature["host"])}</span><h3>{esc(feature["title"])}</h3><p>{esc(feature["summary"])}</p><span class="card-end">Screenshots & guide ↗</span></div></a>')
ext='<p class="lead">Inspect products, understand failed checks and edit contracts. Explore each feature with its own original screenshots and step-by-step guide.</p><div class="actions"><a class="button" href="/extension/reference/#install">Install the extension ↗</a><a href="https://github.com/dataraft-r/dataraft-positron">Extension source</a></div><p class="notice">All screenshots show the real extension running in Positron with synthetic test data. YAML editing is also supported in VS Code. Live R features require Positron and dataraft.ide.</p><h2>Explore the extension, one feature at a time</h2><div class="feature-grid">'+''.join(gallery)+'</div>'
ext+='''<h2>Choose your editor</h2><table><thead><tr><th>Capability</th><th>Positron</th><th>VS Code</th></tr></thead><tbody><tr><td>ODCS contract YAML editor, preview and apply</td><td>Yes</td><td>Yes</td></tr><tr><td>Open metadata JSON snapshots</td><td>Yes</td><td>Yes</td></tr><tr><td>Inspect a live R workspace</td><td>With dataraft.ide</td><td>Not supported</td></tr><tr><td>Trial, R rule diagnostics and bounded R viewer</td><td>With an active, trusted R session</td><td>Not supported</td></tr></tbody></table><h2>More commands and operational guidance</h2><p>Saved-contract validation, table profiling, bounded sample checks, workspace/lake selection and frozen report metadata are covered in the complete command and installation guide. The gallery above documents the native journeys with dedicated captures; it does not claim a screenshot for every command.</p><p><a href="/extension/reference/">Installation, commands, settings and limitations →</a></p>'''
ext+='<h2>About these screenshots</h2><p>Each image is an original 1600 × 1000 capture from the running native application. The capture suite executes real R trials, checks their results and drives the production editor controls. No interface elements have been reconstructed or composited.</p><p><a href="'+evidence['run_url']+'">View the capture run and its evidence ↗</a></p>'
add('/extension/','DataRaft for Positron & VS Code',ext,'Extension')
s=(UP/'dataraft-positron/README.md').read_text();s=s[s.index('## Install'):]
add('/extension/reference/','Extension installation & reference',md(s,'dataraft-positron'),'Extension',source=('dataraft-positron','README.md'))

from training import register
training_nav=register(add,pages,OUT,code)
pages['/learn/']['body']='<p class="notice">Learn by doing: <a href="/training/">DataRaft step by step</a>, the complete hands-on course with a downloadable R script.</p>'+pages['/learn/']['body']
pages['/']['body']=pages['/']['body'].replace('<section class="install-band">', '<section class="section"><span class="eyebrow">HANDS-ON COURSE</span><h2>DataRaft step by step.</h2><p>From local data and quality checks to DuckLake and Positron. Small exercises, one continuous example and a complete R script.</p><a class="button" href="/training/">Explore the course →</a></section><section class="install-band">')
nav=[('/start/','Get started'),('/training/','Training'),('/learn/','Learn'),('/packages/','Packages'),('/reference/','Reference'),('/extension/','Positron + VS Code')]
def side(url,section):
 links='<span class="side-label">DOCUMENTATION</span>'+''.join(f'<a class="{"active" if url.startswith(u) else ""}" href="{u}">{t}</a>' for u,t in nav)
 if section=='Training':
  links+='<span class="side-label">LEARNING PATH</span>'+''.join(f'<a class="{"active" if url==u else ""}" href="{u}">{t}</a>' for u,t in training_nav)
 elif section=='Extension':
  links+='<span class="side-label">EXTENSION GUIDES</span>'+''.join(f'<a class="{"active" if url=="/extension/"+f["slug"]+"/" else ""}" href="/extension/{f["slug"]}/">{esc(f["title"])}</a>' for f in features)
 elif section=='Get started':links+='<span class="side-label">YOUR FIRST PRODUCT</span>'+''.join(f'<a class="{"active" if url==f"/start/{i+1}/" else ""}" href="/start/{i+1}/">{i+1}. {t}</a>' for i,t in enumerate(start_titles))
 else:links+='<span class="side-label">THE PACKAGE FAMILY</span>'+''.join(f'<a class="{"active" if url.startswith("/packages/"+p+"/") else ""}" href="/packages/{p}/">{p}</a>' for p in packages)
 return '<aside class="sidebar"><nav aria-label="Documentation">'+links+'</nav></aside>'
search=[]
for url,p in pages.items():
 soup=BeautifulSoup(p['body'],'html.parser');toc=[];seen=set()
 for h in soup.find_all(['h2','h3']):
  ident=re.sub(r'[^a-z0-9]+','-',h.get_text().lower()).strip('-');base=ident;n=2
  while ident in seen:ident=base+'-'+str(n);n+=1
  seen.add(ident);h['id']=ident
  if h.name=='h2':toc.append((ident,h.get_text()))
 body=str(soup);title=p['title'];source=p['source']
 sourcehtml=f'<div class="source-note">Documentation snapshot: 23 September 2026 · <a href="https://github.com/dataraft-r/{source[0]}/blob/{sha[source[0]]}/{source[1]}">View source at {sha[source[0]][:7]} ↗</a><br>Code examples are documented source examples; they are not executed in this website build.</div>' if source else ''
 header='<header><a class="brand" href="/" aria-label="DataRaft home"><span class="brand-mark">D<span>R</span></span>DataRaft<span class="brand-docs">/ docs</span></a><nav aria-label="Main">'+''.join(f'<a href="{u}" class="{"active" if url.startswith(u) else ""}">{t}</a>' for u,t in nav)+'</nav><div class="header-actions"><button id="search-open" aria-label="Search documentation">Search <kbd>/</kbd></button><a class="github" href="https://github.com/dataraft-r">GitHub ↗</a><button id="menu-toggle" aria-label="Toggle navigation" aria-expanded="false">☰</button></div></header>'
 toc_html='<aside class="toc"><span class="side-label">ON THIS PAGE</span>'+''.join(f'<a href="#{i}">{esc(t)}</a>' for i,t in toc)+'</aside>'
 main=f'<main id="main" class="home">{body}</main>' if url=='/' else f'<div class="doc-layout">{side(url,p["section"])}<main id="main" class="article"><div class="breadcrumb">Documentation <span>/</span> {p["section"]}</div><h1>{esc(title)}</h1>{body}{sourcehtml}</main>{toc_html}</div>'
 footer='<footer><a class="brand" href="/">DataRaft</a><p>Checked data. Reusable definitions. Evidence you can inspect.</p><div><a href="/learn/contributing/">Contribute</a><a href="/learn/security/">Security</a><a href="/learn/compatibility/">Compatibility</a><a href="https://github.com/dataraft-r">GitHub</a></div><small>© 2026 Jan-Hendrik Weinert · MIT licensed · Development documentation</small></footer>'
 search_dialog='<dialog id="search-dialog" aria-labelledby="search-title"><div class="dialog-head"><h2 id="search-title">Search documentation</h2><button id="search-close" aria-label="Close search">✕</button></div><label class="sr-only" for="search-input">Search by function, topic or package</label><input id="search-input" type="search" placeholder="Try dr_product, contracts or DuckLake…" autocomplete="off"><div id="search-results" aria-live="polite"><p>Search functions, packages and guides.</p></div></dialog>'
 doc='<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>'+esc(title)+' · DataRaft</title><meta name="description" content="'+esc(p['desc'] or title+' | DataRaft documentation',quote=True)+'"><meta name="theme-color" content="#103d49"><link rel="icon" href="/assets/favicon.svg" type="image/svg+xml"><link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" defer></script></head><body><a class="skip" href="#main">Skip to content</a>'+header+main+footer+search_dialog+'</body></html>'
 target=OUT/url.lstrip('/')/'index.html';target.parent.mkdir(parents=True,exist_ok=True);target.write_text(doc)
 search.append(dict(url=url,title=title,section=p['section'],text=soup.get_text(' ',strip=True)[:14000]))
(OUT/'assets/search.json').write_text(json.dumps(search))
(OUT/'404.html').write_text('<!doctype html><html lang="en"><meta charset="utf-8"><title>Page not found · DataRaft</title><link rel="stylesheet" href="/assets/site.css"><main class="article"><h1>Page not found</h1><p>This documentation page may have moved.</p><a class="button" href="/">Return to DataRaft</a></main></html>')
print(f'Built {len(pages)} pages, {sum(len(x) for x in refs.values())} reference topics.')

# Retain public pkgdown entry points when moving to the family documentation.
redirects = {"articles/" + Path(u).name + ".html": u for u in pages if u.startswith("/learn/")}
redirects["articles/get-started.html"] = "/start/"
for pkg, entries in refs.items():
    for p, _, _, url in entries:
        redirects[f"components/{pkg}/reference/{p.stem}.html"] = url
        if pkg == "dataraft": redirects[f"reference/{p.stem}.html"] = url
    redirects[f"components/{pkg}/index.html"] = f"/packages/{pkg}/"
    redirects[f"components/{pkg}/reference/index.html"] = f"/packages/{pkg}/reference/"
for old, new in redirects.items():
    f=OUT/old; f.parent.mkdir(parents=True,exist_ok=True)
    f.write_text('<!doctype html><html lang="en"><head><meta charset="utf-8"><title>DataRaft documentation</title><meta http-equiv="refresh" content="0;url='+new+'"></head><body><a href="'+new+'">Continue to the documentation</a></body></html>')
base = os.environ.get("BASE_PATH", "").rstrip("/")
if base and (not base.startswith("/") or ".." in base):
    raise ValueError("BASE_PATH must be an absolute URL path")
for f in OUT.rglob("*.html"):
    soup=BeautifulSoup(f.read_text(),"html.parser")
    if soup.html: soup.html["data-base"] = base
    for el in soup.find_all(True):
        for attr in ("href", "src"):
            v=el.get(attr, "")
            if v.startswith("/") and not v.startswith("//"): el[attr]=base+v
        if el.name=="meta" and el.get("http-equiv", "").lower()=="refresh":
            el["content"]=el["content"].replace("url=/", "url="+base+"/")
    f.write_text(str(soup))
if base:
    index=json.loads((OUT/"assets/search.json").read_text())
    for record in index: record["url"]=base+record["url"]
    (OUT/"assets/search.json").write_text(json.dumps(index))
(OUT/".nojekyll").touch()
