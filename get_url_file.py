#!/usr/bin/env python3

import os
import sys
from urllib.parse import urlparse

if len(sys.argv) < 2:
    print("Usage: " + sys.argv[0] + " <url>")
    sys.exit(2)

url = sys.argv[1]
parsed = urlparse(url)
print(os.path.basename(parsed.path))
