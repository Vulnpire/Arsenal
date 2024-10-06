import asyncio
import aiohttp
import re
import json
import logging

logging.basicConfig(level=logging.INFO)

async def send_request(session, url, patterns):
    try:
        async with session.get(url, timeout=10, headers={'User-Agent': 'Mozilla/5.0 (Linux 6.5.0; ; ) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.6422.60 Chrome/125.0.6422.60 Not.A/Brand/24  Safari/537.36'}) as response:
            text = await response.text()
            for pattern in patterns:
                result = re.findall(pattern['pattern'], text)
                if result:
                    logging.info(f"{pattern['apiName']} found in {url}")
                    logging.info(f"Value is {set(result)}")
    except aiohttp.ClientError as e:
        logging.error(f"Error while scanning {url}: {e}")

async def scan(urls):
    patterns = []
    with open('regex.json', 'r') as file:
        patterns = json.load(file)
    async with aiohttp.ClientSession() as session:
        tasks = [send_request(session, url, patterns) for url in urls]
        await asyncio.gather(*tasks)

def main():
    file = input("Enter a text file: ")
    with open(file, 'r') as f:
        urls = f.read().splitlines()

    loop = asyncio.get_event_loop()
    loop.run_until_complete(scan(urls))

if __name__ == "__main__":
    main()