"""Render the English training from its executable R source, without running R."""
from pathlib import Path
import re, html, shutil

ROOT = Path(__file__).parent
DOWNLOAD = '/downloads/dataraft_training.R'
GROUPS = [
 ('foundations', '01', 'Data, products and quality', 'H', 1, 11, 'Start with six policies in memory. Define requirements, find errors and add a recipe.'),
 ('relationships', '02', 'Persistence and relationships', 'H', 12, 20, 'Save locally, read a delivery back and connect policies with customers and brokers.'),
 ('metrics', '03', 'A cancellation rate you can explain', 'H', 21, 24, 'Define the period, population, numerator and denominator. Check an empty population too.'),
 ('ducklake', '04', 'DuckLake, releases and reports', 'H', 25, 39, 'Extend the local example with releases, corrections, frozen reports and lineage.'),
 ('extension', '05', 'The extension in your workspace', 'E', 1, 15, 'Use your existing objects for small manual exercises in Positron and VS Code.'),
 ('deep-dives', '06', 'Adapters and additional tools', 'V', 1, 25, 'Choose relevant integrations: pointblank, dbt, targets, catalogs, PostgreSQL, S3 and custom adapters.'),
]

def route(key): return '/training/' + key.lower() + '/'

def register(add, pages, out, code):
    source = ROOT/'content/training/dataraft_training.R'
    text = source.read_text()
    sections = re.split(r'^# (.+?) ----\s*$', text, flags=re.M)
    blocks = [(sections[i], sections[i+1].strip()) for i in range(1,len(sections),2)]
    lessons = {}; extra = []
    for title, body in blocks:
        match = re.match(r'([HEV]\d{2})[a-z]?\s',title)
        if match: lessons.setdefault(match[1], []).append((title,body))
        else: extra.append((title,body))
    assert len(lessons)==79, f'Expected 79 modules, got {len(lessons)}'
    targets = {key:route(key) for key in lessons}
    def prose(lines):
        raw = '\n'.join(re.sub(r'^# ?', '', s) for s in lines).strip()
        result=[]
        # Split pedagogical labels into individual paragraphs, keeping continuations.
        chunks=re.split(r'\n(?=(?:Goal|Prerequisites|Expected result|Task|Solution|Check|Next|MANUAL):)|\n\s*\n',raw)
        for chunk in chunks:
            if not chunk.strip():continue
            value=html.escape(' '.join(chunk.splitlines()))
            value=re.sub(r'\b([HEV]\d{2})([a-z]?)\b',lambda m:f'<a href="{targets[m[1]]}">{m[0]}</a>' if m[1] in targets else m[0],value)
            value=re.sub(r'(https://github\.com/[^\s<]+)',r'<a href="\1">\1</a>',value)
            m=re.match(r'([^:]+): (.*)',value,re.S)
            if m and m[1]=='Solution':
                result.append('<details class="training-solution"><summary>Show solution</summary><p>'+m[2]+'</p></details>')
            elif m and m[1] in ('Goal','Prerequisites','Expected result','Task','Check','MANUAL'):
                result.append('<p class="training-'+('task' if m[1]=='Task' else 'note')+'"><strong>'+m[1]+':</strong> '+m[2]+'</p>')
            else:result.append('<p>'+value+'</p>')
        return ''.join(result)
    def render(body):
        result=[]; buf=[]; kind=None
        # Only top-level comments become prose. Indented code comments remain code.
        for line in body.splitlines()+['#']:
            next_kind='prose' if line.startswith('#') else 'code' if line.strip() else kind
            if next_kind!=kind and buf:
                result.append(prose(buf) if kind=='prose' else code('\n'.join(buf)))
                buf=[]
            buf.append(line);kind=next_kind
        if buf:result.append(prose(buf) if kind=='prose' else code('\n'.join(buf)))
        return ''.join(result)
    download=f'<a class="button" href="{DOWNLOAD}" download>Download the R script ↓</a>'
    intro='<p class="lead">From your first local table to a checked, reproducible report. Learn DataRaft in small steps, with one insurance example and a complete executable R script.</p>'
    intro+='<div class="meta-row"><span>Hands-on R course</span><span>39 main modules</span><span>15 extension modules</span><span>25 deep dives</span></div>'
    intro+='<div class="actions"><a class="button" href="/training/setup/">Start with preparation →</a>'+download+'</div>'
    intro+='''<h2>How to use this course</h2><ol><li>Download the R script and open it in Positron in a separate R session.</li><li>Read the goal and prerequisites on the website. Run the corresponding script section, allowing about 5 to 10 minutes per small step.</li><li>Compare your output with the expected result. Try the task before opening its solution.</li></ol><p>The website accompanies your local R session. It does not execute R in the browser. Code blocks match the download and use the explained course helper from H05 onward: <code>training_step()</code>. Keep earlier objects available and follow the prerequisites.</p><h2>Your learning path</h2>'''
    nav=[]
    for slug,num,title,prefix,lo,hi,desc in GROUPS:
        url=route(slug);nav.append((url,title))
        keys=[f'{prefix}{n:02}' for n in range(lo,hi+1)]
        intro+=f'<a class="training-path" href="{url}"><span class="training-number">{num}</span><span><strong>{title}</strong><span>{desc}</span><small>{keys[0]} to {keys[-1]} · {len(keys)} modules →</small></span></a>'
        groupbody=f'<p class="lead">{desc}</p><p>Work through each module in the displayed order. Prerequisite links lead to the earlier modules you need.</p><div class="function-list">'
        for key in keys:
            name=next(t for t,b in lessons[key] if t.startswith(key+' '))
            goal=re.search(r'^# Goal: (.*)', lessons[key][0][1],re.M)
            groupbody+=f'<a href="{route(key)}"><strong>{html.escape(name)}</strong><span>{html.escape(goal[1]) if goal else "Manual editor exercise"}</span></a>'
        groupbody+='</div><p><a href="/training/">← Full learning path</a></p>'
        add(url,title,groupbody,'Training',desc)
    intro+='<h2>Requirements and validation</h2><p>Basic R knowledge is enough to begin. Start without a database or cloud. Enable DuckLake, interactive interfaces and external services when you reach those exercises.</p><p><a href="/training/setup/">Setup and course runner</a> · <a href="/training/reference/">Pinned versions and closing steps</a></p>'
    add('/training/','DataRaft step by step',intro,'Training','A hands-on R course: start locally, check products and progress to DuckLake and Positron.')
    setup=extra[:4]+[next(x for x in extra if x[0].startswith('Course runner'))]
    setupbody='<p class="lead">Prepare once, then continue in the same R session.</p>'+download
    setupbody+='<p>The download places H01 to H04 before the course runner. If copying from this website, run only Preparation: load the package first, complete H01 to H04, then return here and run the course runner. This keeps your objects and log consistent with the script.</p>'
    for title,body in setup:
        setupbody+='<h2>'+html.escape(title)+'</h2>'
        # Configuration/installation are intentionally comments; preserve as copyable R.
        setupbody+=code(body) if title.startswith('00 Optional') else render(body)
    setupbody+='<div class="chapter-nav"><a href="/training/">← Learning path</a><a href="/training/h01/">H01: Your first table →</a></div>'
    add('/training/setup/','Preparation and course runner',setupbody,'Training')
    sequence=[f'H{n:02}' for n in range(1,40)]+[f'E{n:02}' for n in range(1,16)]+[f'V{n:02}' for n in range(1,26)]
    for i,key in enumerate(sequence):
        title=next(t for t,b in lessons[key] if t.startswith(key+' '))
        group=next(g for g in GROUPS if g[3]==key[0] and g[4]<=int(key[1:])<=g[5])
        body=f'<div class="meta-row"><span>{key}</span><span>{group[2]}</span><span>{len(lessons[key])} {"step" if len(lessons[key])==1 else "steps"}</span></div>'
        body+='<p class="training-context">Use your current course session. <a href="/training/setup/">Preparation and course runner</a> · <a href="'+DOWNLOAD+'" download>R script ↓</a></p>'
        if key=='H05':body+='<p class="notice">Now run the course runner from the script, immediately after H04. It defines <code>training_step()</code>, options and the training directory. <a href="/training/setup/#course-runner-for-the-following-modules">Open the course runner →</a></p>'
        if key=='H25':body+='<p class="notice">These exercises need DuckLake. Enable the lake option and prepare the listed packages as described in the script. For a local alternative without the DuckLake extension, see <a href="/training/v25/">V25</a>.</p>'
        if key=='E01':body+=render(next(b for t,b in extra if t.startswith('Extension exercises')))+'<p><a href="/extension/">Extension screenshots and installation guide →</a></p>'
        if key.startswith('V'):body+='<p class="notice">Optional deep dive. Enable only the options named in each block, after preparing its packages or services.</p>'
        for st,sb in lessons[key]:body+='<h2>'+html.escape(st)+'</h2>'+render(sb)
        prev=route(sequence[i-1]) if i else '/training/setup/'
        nxt=route(sequence[i+1]) if i+1<len(sequence) else '/training/reference/'
        body+=f'<div class="chapter-nav"><a href="{prev}">← {sequence[i-1] if i else "Preparation"}</a><a href="{route(group[0])}">Chapter overview</a><a href="{nxt}">{sequence[i+1] if i+1<len(sequence) else "Finish"} →</a></div>'
        add(route(key),title,body,'Training')
    refbody='<p class="lead">Review what actually ran, and close connections only after the UI exercises.</p>'
    for title,body in extra:
        if (title,body) not in setup and not title.startswith('Extension exercises'):refbody+='<h2>'+html.escape(title)+'</h2>'+render(body)
    refbody+='<p><a href="/training/setup/">Preparation</a> records the validation scope and test environment. The website build does not rerun R. Explore the <a href="/reference/">function reference</a> for API details.</p>'

    add('/training/reference/','Finish and pinned components',refbody,'Training')
    (out/'downloads').mkdir(exist_ok=True)
    shutil.copy2(source,out/'downloads'/source.name)
    return [('/training/','Overview'),('/training/setup/','Preparation')]+nav+[('/training/reference/','Finish and reference')]
