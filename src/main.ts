import 'dotenv/config';
import { PlaywrightCrawler } from 'crawlee';
import fs from 'fs';
import { autoScroll } from './utils/scroll';

const allProducts: any[] = [];

// 🔹 Pages you want to crawl
const urls = [
  'https://warehouse-theme-metal.myshopify.com/collections/tv-accessories?page=1',
  'https://warehouse-theme-metal.myshopify.com/collections/tv-accessories?page=2',
  'https://warehouse-theme-metal.myshopify.com/collections/tv-accessories?page=3',
  'https://warehouse-theme-metal.myshopify.com/collections/tv-accessories?page=4'
];

const crawler = new PlaywrightCrawler({
  headless: true, // Browser runs in the background without showing the UI
  maxRequestsPerCrawl: urls.length, // Maximum number of requests
  navigationTimeoutSecs: 60, // Maximum time per page

  async requestHandler({ page, log, request }) {
    log.info(`🕷️ Crawling: ${request.url}`);
    await autoScroll(page); // Scroll the page fully

    const products = await page.$$eval('.product-item', items =>
      items.map(item => ({
        title: item.querySelector('.product-item__title')?.textContent?.trim() || 'No Title',
        price: item.querySelector('.price')?.textContent?.replace(/\s+/g, ' ').trim() || 'No Price',
        image: item.querySelector('.product-item__primary-image')?.getAttribute('src') || 'No Image',
        link: item.querySelector('a')?.href || window.location.href,
        isGood: null // Left empty for now, OpenAI can fill this later
      }))
    );

    allProducts.push(...products); // Add the found products to the main list
  }
});

// 🔹 Run the crawler
await crawler.run(urls);

// 🔹 Save products to JSON
fs.writeFileSync('products.json', JSON.stringify(allProducts, null, 2));
console.log('✅ products.json saved successfully');
