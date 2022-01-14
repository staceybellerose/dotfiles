#!/usr/bin/env python3

from bs4 import BeautifulSoup
import requests
import sys

if len(sys.argv) < 2:
    print("Usage: " + sys.argv[0] + " <url>")
    sys.exit(2)

url = sys.argv[1]
html_page = requests.get(url)
soup = BeautifulSoup(html_page.text, features="lxml")
for link in soup.findAll('a'):
    print(requests.compat.urljoin(url, link.get('href')))
