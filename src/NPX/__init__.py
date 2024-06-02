"""Pipeline to output SHF exchange format npx in csv"""

__version__ = "0.0.1"  # first version

import argparse
from NPX.ford3 import ford3

def ford():
    parser = argparse.ArgumentParser(description="Automation for SHF chain")
    parser.add_argument(
        "-i",
        "--input",
        required=True,
        help="Source file with Zetcom data to be transformed into npx/csv",
    )
    parser.add_argument(
        "-f",
        "--force",
        help="Overwrite existing files",
        action="store_true",
        default=False,
    )
    parser.add_argument(
        "-v",
        "--version",
        type=int,
        help="Specify version of mapping",
        choices=[1, 2],
        default=1,
    )
    parser.add_argument(
        "-r",
        "--restriction",
        help="Restrict the multimedia items",
        choices=["smb", "all"],
        default="smb",
    )
    args = parser.parse_args()
    ford3(args.input, force=args.force, assets=args.restriction, version=args.version)
