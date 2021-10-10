#!/usr/bin/env python3

from lamden.crypto.wallet import Wallet


def print_keys():
    w = Wallet()
    print('-_-')
    print(f"verifying key: {w.verifying_key}")
    print(f"signing key: {w.signing_key}")


if __name__ == '__main__':
    for i in range(3):
        print_keys()
