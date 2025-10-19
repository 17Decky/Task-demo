import asyncio
import aiohttp
import time

URL = "http://10.105.227.84:5000/"  # use only on servers you control
CONCURRENCY = 100
TOTAL = 1000

async def send(session, i):
    try:
        async with session.get(URL, timeout=5) as resp:
            # don't read resp.text(); just record status
            print(f"[{i}] {resp.status}")
    except Exception as e:
        print(f"[{i}] error: {e}")

async def main():
    conn = aiohttp.TCPConnector(limit=CONCURRENCY)
    timeout = aiohttp.ClientTimeout(total=10)
    async with aiohttp.ClientSession(connector=conn, timeout=timeout) as session:
        tasks = [asyncio.create_task(send(session, i+1)) for i in range(TOTAL)]
        # Option A: Wait for all to finish (gives you completion)
        await asyncio.gather(*tasks)

if __name__ == "__main__":
    t0 = time.time()
    asyncio.run(main())
    print("done in", time.time() - t0)
