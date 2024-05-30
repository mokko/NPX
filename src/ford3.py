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

# import os
from pathlib import Path
from saxonche import PySaxonProcessor
import xml.etree.ElementTree as ET

mpx2npx = Path(__file__).parent.parent / "xsl" / "zpx2npx.xsl"
mpx2waf = Path(__file__).parent.parent / "xsl" / "zpx2waf.xsl"
mpx2npx_all = Path(__file__).parent.parent / "xsl" / "zpx2npx-alleAssets.xsl"

NSMAP = {
    "npx": "http://www.mpx.org/npx",  # npx is no mpx
}


def main(
    src: str | Path, *, force: bool = False, assets: str = "smb", waf: bool = False
) -> None:
    p = Path(src)
    date = p.parent.name  # takes date from source directory, not current date
    pro_label = p.parent.parent.name
    pro_dir = Path(__file__).parent.parent / "sdata" / pro_label / date
    npx_fn = pro_dir / Path(p.name).with_suffix(".npx.xml")
    waf_fn = pro_dir / Path(p.name).with_suffix(".waf.xml")
    print(f"* Force parameter is set to '{force}'")
    print(f"* Asset restriction set to '{assets}'")
    print(f"* Using project dir '{pro_dir}'")
    print(f"* For waf '{waf}'")
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

    if waf:
        _saxon(p, mpx2waf, waf_fn)

    todo = {
        "so": {"fn": pro_dir / f"{p.stem}-so.csv", "xpath": "./npx:sammlungsobjekt"},
        "mm": {"fn": pro_dir / f"{p.stem}-mm.csv", "xpath": "./npx:multimediaobjekt"},
        "waf": {"fn": pro_dir / f"{p.stem}-waf.csv", "xpath": "./npx:sammlungsobjekt"},
    }

    if not waf:
        del todo["waf"]

    for each in todo:
        fn = todo[each]["fn"]
        xpath = todo[each]["xpath"]
        if force is True or not fn.exists():
            _writeCsv(src=npx_fn, csv_fn=fn, xpath=xpath)
        else:
            print(f"* Not overwriting csv file '{fn.name}'")


#
# somewhat private
#


def _saxon(src: str | Path, xsl: str | Path, target: str | Path) -> None:
    """
    New hack to using saxonche.
    """
    xml_file_name = Path(src).absolute().as_uri()
    with PySaxonProcessor(license=False) as proc:
        xsltproc = proc.new_xslt30_processor()
        executable = xsltproc.compile_stylesheet(stylesheet_file=str(xsl))
        xml = proc.parse_xml(xml_file_name=xml_file_name)
        result_tree = executable.apply_templates_returning_file(
            xdm_node=xml, output_file=str(target)
        )


def _writeCsv(*, src: Path, csv_fn: Path, xpath: str):
    """
    Transform npx at src to csv at csv_fn using the xpath expression to pick object type.

    npx elements under the moduleItem level are aspects of the object.
    """
    columns = set()  # distinct list for columns for csv table
    npx = ET.parse(src)
    # Looping thru all records to determine all attributes
    for itemN in npx.findall(xpath, NSMAP):
        # print(f"***{itemN}")
        for aspect in itemN.findall("*"):
            tag = aspect.tag.split("}")[1]  # strip ns
            columns.add(tag)
    columnsL = sorted(columns)

    print(f"* Writing csv {csv_fn}")
    with open(csv_fn, mode="w", newline="", encoding="utf-8") as csvfile:
        out = csv.writer(csvfile, dialect="excel")
        out.writerow(columnsL)  # headers
        # print (f"{columnsL}")
        for itemN in npx.findall(xpath, NSMAP):
            row = []
            for aspectN in columnsL:
                # print(f"{aspectN}")
                element = itemN.find(f"./npx:{aspectN}", NSMAP)
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
        "-w",
        "--waf",
        help="Add another file for wafs",
        action="store_true",
    )
    parser.add_argument(
        "-r",
        "--restriction",
        help="Restrict the multimedia items",
        choices=["smb", "all"],
        default="smb",
    )
    args = parser.parse_args()
    main(args.input, force=args.force, assets=args.restriction, waf=args.waf)
