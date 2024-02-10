"""
A new script to transform mpx data to npx and csv

Should write to ../sdata/ProjectLabel/20240209.

Currently we accept only single files as input.
"""
import csv
import os
from pathlib import Path
import subprocess
import xml.etree.ElementTree as ET

saxLib = os.environ["saxLib"]
mpx2npx = Path(__file__).parent.parent / "xsl" / "zpx2npx.xsl"


def main(src: str, *, force: bool = False) -> None:
    src = Path(src)
    date = src.parent.name
    pro_label = src.parent.parent.name
    pro_dir = Path(__file__).parent.parent / "sdata" / pro_label / date
    npx_fn = pro_dir / Path(src.name).with_suffix(".npx.xml")
    so = Path(src.stem + "-so")
    mm = Path(src.stem + "-mm")
    so_fn = pro_dir / so.with_suffix(".csv")
    mm_fn = pro_dir / mm.with_suffix(".csv")
    print(f"About to save at '{npx_fn}'")
    if not pro_dir.exists():
        pro_dir.mkdir(parents=True)

    if not npx_fn.exists() or force is True:
        _saxon(src, mpx2npx, npx_fn)

    if not so_fn or force is True:
        _writeCsv(src=npx_fn, fn=so_fn, xpath="npx:sammlungsobjekt")

    if not mm_fn or force is True:
        _writeCsv(src=npx_fn, fn=mm_fn, xpath="npx:multimediaobjekt")


def _writeCsv(*, src, fn, xpath):
    columns = set()  # distinct list for columns for csv table
    ns = {
        "npx": "http://www.mpx.org/npx",  # npx is no mpx
    }

    npx_tree = ET.parse(src)

    # Loop1: identify attributes
    for so in npx_tree.findall(f"./{xpath}", ns):
        for aspect in so.findall("*"):
            tag = aspect.tag.split("}")[1]
            columns.add(tag)
    # verbose (sorted (columns))
    print(f"Writing csv {fn}")
    with open(fn, mode="w", newline="", encoding="utf-8") as csvfile:
        out = csv.writer(csvfile, dialect="excel")
        out.writerow(sorted(columns))  # headers
        # print (sorted(columns))

        for so in npx_tree.findall(f"./{xpath}", ns):
            row = []
            for aspect in sorted(columns):
                element = so.find("./npx:" + aspect, ns)
                if element is not None:
                    # print (aspect+':'+str(element.text))
                    row.append(element.text)
                else:
                    row.append("")
            out.writerow(row)  # headers


def _saxon(src, xsl, target) -> None:
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
        help="Force. Overwrite existing files.",
        action="store_true",
        default=False,
    )
    args = parser.parse_args()

    main(args.input, force=args.force)
