"""
A new script to transform mpx data to npx and csv

This script writes to 
    zml2npx/sdata/ProjectLabel/20240209 etc.
independent from where it's executed.

Currently we accept only a single file as input.

NEW 
23.2.2024
* Added argument for exporting with all or only smb-approved assets.
"""
import csv
import os
from pathlib import Path
import subprocess
import xml.etree.ElementTree as ET

saxLib = os.environ["saxLib"]
mpx2npx = Path(__file__).parent.parent / "xsl" / "zpx2npx.xsl"
mpx2npx_all = Path(__file__).parent.parent / "xsl" / "zpx2npx-alleAssets.xsl"

ns = {
    "npx": "http://www.mpx.org/npx",  # npx is no mpx
}


def main(src: str | Path, *, force: bool = False, assets: str = "smb") -> None:
    p = Path(src)
    date = p.parent.name  # takes date from source directory, not current date
    pro_label = p.parent.parent.name
    pro_dir = Path(__file__).parent.parent / "sdata" / pro_label / date
    npx_fn = pro_dir / Path(p.name).with_suffix(".npx.xml")
    so_fn = pro_dir / f"{p.stem}-so.csv"
    mm_fn = pro_dir / f"{p.stem}-mm.csv"
    print(f"* Force parameter is set to '{force}'")
    print(f"* Asset restriction set to '{assets}'")
    print(f"* Using project dir '{pro_dir}'")
    if not pro_dir.exists():
        pro_dir.mkdir(parents=True)

    if force is True or not npx_fn.exists():
        print(f"* '{npx_fn}' doesn't exist yet.")
        match assets:
            case "smb":
                _saxon(p, mpx2npx, npx_fn)
            case "all":
                _saxon(p, mpx2npx_all, npx_fn)
            case _:
                raise SyntaxError(
                    f"ERROR: Unknown value for asset restriction: '{assets}'"
                )
    else:
        print(f"* Not overwriting npx file '{npx_fn.name}'")

    todo = {
        "so": {"fn": so_fn, "xpath": "./npx:sammlungsitem"},
        "mm": {"fn": mm_fn, "xpath": "./npx:multimediaitem"},
    }

    for each in todo:
        each2 = todo[each]
        if force is True or not each2["fn"].exists():
            _writeCsv(src=npx_fn, csv_fn=each2["fn"], xpath=each2["xpath"])
        else:
            print(f"* Not overwriting csv file '{each2['fn'].name}'")


def _saxon(src: str | Path, xsl: str | Path, target: str | Path) -> None:
    """
    My usual hack to use saxon from Python.

    Assumes there is java in path.
    """

    cmd = f"java -Xmx1450m -jar {saxLib} -s:{src} -xsl:{xsl} -o:{target}"
    print(cmd)

    subprocess.run(
        cmd, check=True  # , stderr=subprocess.STDOUT
    )  # overwrites output file without saying anything


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
    columnsL = sorted(columns)

    print(f"* Writing csv {csv_fn}")
    with open(csv_fn, mode="w", newline="", encoding="utf-8") as csvfile:
        out = csv.writer(csvfile, dialect="excel")
        out.writerow(columnsL)  # headers
        # print (columnsL)

        for item in npx_tree.findall(xpath, ns):
            row = []
            for aspectN in columnsL:
                element = item.find(f"./npx:{aspectN}", ns)
                if element is not None:
                    row.append(element.text)
                else:
                    row.append("")
            out.writerow(row)


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
    parser.add_argument(
        "-r",
        "--restriction",
        help="Restrict the multimedia items",
        choices=["smb", "all"],
        default="smb",
    )
    args = parser.parse_args()
    main(args.input, force=args.force, assets=args.restriction)
