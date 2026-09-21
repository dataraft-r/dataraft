const { chromium } = require('playwright');
const AxeBuilder = require('@axe-core/playwright').default;
const fs = require('node:fs');
(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();
  const results = [];
  let failed = false;
  try {
    for (const [name, url] of [['quality', 'http://127.0.0.1:8765/quality.html'], ['catalog', 'http://127.0.0.1:8766']]) {
      await page.goto(url);
      if (name === 'catalog') {
        await page.waitForFunction(() => window.Shiny && Shiny.shinyapp && Shiny.shinyapp.$socket && Shiny.shinyapp.$socket.readyState === 1);
        await page.locator('#search').waitFor();
        await page.getByRole('tab').first().waitFor();
      }
      const audit = async label => {
        const result = await new AxeBuilder({page}).withTags(['wcag2a', 'wcag2aa', 'wcag21aa', 'wcag22aa']).analyze();
        results.push({name: label, violations: result.violations, incomplete: result.incomplete});
        failed ||= result.violations.length > 0;
      };
      await audit(name);
      if (name === 'catalog') {
        const tabs = page.getByRole('tab');
        if (await tabs.count() !== 7) throw new Error('Expected seven accessible catalog tabs');
        for (let i = 0; i < await tabs.count(); i++) {
          await tabs.nth(i).focus();
          await page.keyboard.press('Enter');
          await page.waitForFunction(() => !document.documentElement.classList.contains('shiny-busy'));
          if (await tabs.nth(i).getAttribute('aria-selected') !== 'true') throw new Error('Keyboard tab activation failed');
          await audit(`${name}-tab-${i}`);
        }
        await page.locator('#search').focus();
        await page.keyboard.type('orders');
        if (await page.locator('#search').inputValue() !== 'orders') throw new Error('Keyboard search failed');
        await page.locator('#search').fill('no-matching-product');
        await page.waitForFunction(() => !document.documentElement.classList.contains('shiny-busy'));
        await audit('catalog-empty-search');
      }
      await page.screenshot({path: `accessibility-artifacts/${name}.png`, fullPage: true});
    }
  } finally {
    fs.writeFileSync('accessibility-artifacts/axe.json', JSON.stringify(results, null, 2));
    await browser.close();
  }
  if (failed) {
    console.error(JSON.stringify(results.filter(x => x.violations.length).map(x => ({name: x.name, violations: x.violations.map(v => ({id: v.id, nodes: v.nodes.map(n => ({target: n.target, summary: n.failureSummary}))}))})), null, 2));
    throw new Error('Accessibility violations found; inspect axe.json');
  }
})().catch(error => {console.error(error); process.exitCode = 1;});
