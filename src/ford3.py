"""
A new script to transform mpx data to npx and csv

This script writes to 
    zml2npx/sdata/ProjectLabel/20240209 etc.
independent from where it's executed.

Currently we accept only a single file as input.
"""
import csv
import os
from pathlib import Path
import subprocess
import xml.etree.ElementTree as ET

saxLib = os.environ["saxLib"]
mpx2npx = Path(__file__).parent.parent / "xsl" / "zpx2npx.xsl"

ns = {
    "npx": "http://www.mpx.org/npx",  # npx is no mpx
}


def main(src: str, *, force: bool = False) -> None:
    src = Path(src)
    date = src.parent.name
    pro_label = src.parent.parent.name
    pro_dir = Path(__file__).parent.parent / "sdata" / pro_label / date
    npx_fn = pro_dir / Path(src.name).with_suffix(".npx.xml")
    so_fn = pro_dir / f"{src.stem}-so.csv"
    mm_fn = pro_dir / f"{src.stem}-mm.csv"
    print(f"Force parameter is set to '{force}'")
    print(f"Would write to '{pro_dir}'")
    if not pro_dir.exists():
        pro_dir.mkdir(parents=True)

    if not npx_fn.exists() or force is True:
        _saxon(src, mpx2npx, npx_fn)
    else:
        print(f"Not writing npx file '{npx_fn.name}'")

    if not so_fn or force is True:
        _writeCsv(src=npx_fn, csv_fn=so_fn, xpath="./npx:sammlungsitem")
    else:
        print(f"Not writing csv file '{so_fn.name}'")

    if not mm_fn or force is True:
        _writeCsv(src=npx_fn, csv_fn=mm_fn, xpath="./npx:multimediaitem")
    else:
        print(f"Not writing csv file '{mm_fn.name}'")


def _writeCsv(*, src: Path, csv_fn: Path, xpath: str):
    """
    Transform npx at src to csv at csv_fn using the xpath expression to pick object type.

    npx elements under the moduleItem level are aspects of the object.
    """
    columns = set()  # distinct list for columns for csv table
    npx_tree = ET.parse(src)

    # Looping thru all records to determine all attributes
    for item in npx_tree.findall(xpath, ns):
        for aspect in item.findall("*"):
            tag = aspect.tag.split("}")[1]  # strip ns
            columns.add(tag)
    columns = sorted(columns)

    print(f"Writing csv {csv_fn}")
    with open(csv_fn, mode="w", newline="", encoding="utf-8") as csvfile:
        out = csv.writer(csvfile, dialect="excel")
        out.writerow(columns)  # headers
        # print (columns)

        for item in npx_tree.findall(xpath, ns):
            row = []
            for aspect in columns:
                element = item.find("./npx:" + aspect, ns)
                if element is not None:
                    row.append(element.text)
                else:
                    row.append("")
            out.writerow(row)


def _saxon(src: str, xsl: str, target: str) -> None:
    """
    My usual hack to use saxon from Python.

    Assumes there is java in path.
    """

    cmd = f"java -Xmx1450m -jar {saxLib} -s:{src} -xsl:{xsl} -o:{target}"
    print(cmd)

    subprocess.run(
        cmd, check=True  # , stderr=subprocess.STDOUT
    )  # overwrites output file without saying anything


if __name__ == "__main__":
    import argparse

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
    args = parser.parse_args()
    main(args.input, force=args.force)
