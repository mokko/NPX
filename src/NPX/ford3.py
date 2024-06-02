"""
A new script to transform mpx data to npx and csv

This script writes to
    zml2npx/sdata/ProjectLabel/20240209 etc.
independent from where it's executed.

Currently we accept only a single file as input.

NEW
31.5.2024
* New mapping (v2) and old mapping (v1)
29.5.2024
* from java saxon to saxonche
23.2.2024
* Added argument for exporting with all or only smb-approved assets.

"""

import csv
from pathlib import Path
from saxonche import PySaxonProcessor
import xml.etree.ElementTree as ET

NSMAP = {
    "npx": "http://www.mpx.org/npx",  # npx is no mpx
}


def ford3(
    src: str | Path, *, force: bool = False, assets: str = "smb", version: int = 1
) -> None:
    p = Path(src)
    date = p.parent.name  # takes date from source directory, not current date
    pro_label = p.parent.parent.name
    pro_dir = Path(__file__).parent.parent / "sdata" / pro_label / date
    npx_fn = pro_dir / f"{p.stem}_v{version}.npx.xml"
    print(f"* Force parameter is set to '{force}'")
    print(f"* Asset restriction set to '{assets}'")
    print(f"* Using project dir '{pro_dir}'")
    print(f"* Mapping version {version}")

    xsl_dir = Path(__file__).parent.parent / "xsl"
    match version:
        case 1:
            if assets == "smb":
                xsl_fn = xsl_dir / "npx_v1.xsl"
            elif assets == "all":
                xsl_fn = xsl_dir / "npx_v1-alleAssets.xsl"
            else:
                raise SyntaxError(f"Unknown asset restriction type {assets}")

        case 2:
            if assets == "smb":
                xsl_fn = xsl_dir / "npx_v2.xsl"
            elif assets == "all":
                xsl_fn = xsl_dir / "npx_v2-alleAssets.xsl"
            else:
                raise SyntaxError(f"Unknown asset restriction type {assets}")
        case _:
            raise SyntaxError(f"Unknown version {version}")

    print(f"* Using xsl entry {xsl_fn}")

    if not pro_dir.exists():
        pro_dir.mkdir(parents=True)

    if force or not npx_fn.exists():
        print(f"* Writing npx '{npx_fn}'")
        _saxon(p, xsl_fn, npx_fn)
    else:
        print(f"* Not overwriting npx file '{npx_fn.name}'")

    todo = {
        "so": {
            "fn": pro_dir / f"{p.stem}_v{version}-so.csv",
            "xpath": "./npx:sammlungsobjekt",
        },
        "mm": {
            "fn": pro_dir / f"{p.stem}_v{version}-mm.csv",
            "xpath": "./npx:multimediaobjekt",
        },
    }

    for each in todo:
        fn = todo[each]["fn"]
        xpath = todo[each]["xpath"]
        if force or not fn.exists():
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


#if __name__ == "__main__":
