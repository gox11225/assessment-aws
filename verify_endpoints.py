#!/usr/bin/env python3

import sys
import requests

def check(url):
    try:
        r = requests.get(url, timeout=5)
        if r.status_code == 200:
            print(f"[PASS] {url} -> {r.status_code}")
            return True
        else:
            print(f"[FAIL] {url} -> {r.status_code}")
            return False
    except requests.RequestException as e:
        print(f"[FAIL] {url} -> {e}")
        return False

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <ALB_DNS>")
        sys.exit(1)

    alb_dns = sys.argv[1]
    endpoints = [
        f"http://{alb_dns}/service-a/health",
        f"http://{alb_dns}/service-b/health",
    ]

    print("=== Checking ALB endpoints ===")
    results = [check(url) for url in endpoints]

    if all(results):
        print("\nAll checks passed.")
        sys.exit(0)
    else:
        print("\nSome checks failed.")
        sys.exit(1)

if __name__ == "__main__":
    main()