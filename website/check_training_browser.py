"""Smoke-test course navigation and layout against a locally built Pages site."""
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from threading import Thread
from playwright.sync_api import sync_playwright, expect
import os, re

ROOT = Path(__file__).parent
BASE = os.environ.get('BASE_PATH', '/dataraft').rstrip('/')
class Handler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if BASE and self.path.startswith(BASE + '/'):
            self.path = self.path[len(BASE):]
        super().do_GET()
    def log_message(self, *args):
        pass

server = ThreadingHTTPServer(('127.0.0.1', 0), partial(Handler, directory=str(ROOT/'dist')))
Thread(target=server.serve_forever, daemon=True).start()
origin = f'http://127.0.0.1:{server.server_port}{BASE}'
artifacts = Path(os.environ.get('RUNNER_TEMP', '/tmp'))/'training-browser'
artifacts.mkdir(exist_ok=True)
try:
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        errors = []
        page.on('pageerror', lambda error: errors.append(str(error)))
        for width in (1440, 1024, 390):
            page.set_viewport_size({'width': width, 'height': 1000})
            page.goto(origin+'/training/')
            assert page.locator('.training-path').count() == 6
            assert page.locator('html').get_attribute('lang') == 'en'
            assert page.evaluate('document.documentElement.scrollWidth <= innerWidth'), width
            page.screenshot(path=str(artifacts/f'overview-{width}.png'), full_page=True)
        page.goto(origin+'/training/h06/')
        page.locator('summary').click()
        assert page.locator('details').evaluate('(el) => el.open')
        page.locator('.copy-button').first.click()
        expect(page.locator('.copy-button').first).to_have_text(re.compile(r'^(Copied|Select to copy)$'))
        page.locator('#search-open').click()
        page.locator('#search-input').fill('cancellation rate')
        page.locator('#search-results a[href*="training"]').first.wait_for()
        page.locator('#search-close').click()
        page.screenshot(path=str(artifacts/'lesson-mobile.png'), full_page=True)
        with page.expect_download() as downloaded:
            page.locator('a[download]').first.click()
        assert Path(downloaded.value.path()).read_bytes() == (ROOT/'content/training/dataraft_training.R').read_bytes()
        page.locator('.chapter-nav a').last.click()
        assert page.url.endswith('/training/h07/')
        assert not errors, errors
        browser.close()
    print('Course browser checks passed: desktop/mobile layout, solutions, copy, search, download and next lesson')
finally:
    server.shutdown()
