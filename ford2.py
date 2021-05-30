"""
Automation for npx/shf. This little script is supposed to grow with time.

We want to send SHF the least amount of packages possible, so may oonvert

#input
sdata/HF-AKu-Module/20210521
sdata/HF-AKu-StuSam/20210521/1.clean-group30356.xml
{DataDir}/{ExhibitOrGroupDir}/{DateDir}/{many *-clean-*.npx.xml files}
sdata/pix_HF-AKu-Module 
sdata/{individual pix dirs}

#target
sdata/HFObjekte/2021521/2-SHF/1.clean-group30356.npx.xml # many npx.xml files
sdata/HFObjekte/2021521/2-SHF/pack.npx # one pack file; duplicates are being weeded out
sdata/HFObjejte/pix/1.jpg #many image files

- New version to be executed in the DataDir 
- We feed the name the current date (i.e. name of DateDir) into the script via commandline 
parameter.
- Output dir from commandline as well b/c it's easy. Not because that is good design.

USAGE
    ford2.py --date 20210523 --output HFObjekte
 
"""

import argparse
import os
import re
import shutil
import sys
from pathlib import Path
from lxml import etree
#adir = Path(__file__).parent
sys.path.append("C:/m3/Pipeline/src")  # what the heck?
from Saxon import Saxon
from lvlup.Npx2csv import Npx2csv

saxon_path = "C:/m3/SaxonHE10-5J/saxon-he-10.5.jar"
zpx2mpx = "C:/m3/zpx2npx/xsl/zpx2npx.xsl"
join_npx = "C:/m3/zpx2npx/xsl/join_npx.xsl"

class Ford:
    def __init__(self, *, date, output):
        #e.g. Afrika-Ausstellung-clean-exhibit20226.xml
        s = Saxon(saxon_path)
        #print (f"DATE{date}")

        #
        # STEP 1 Convert many small group/exhibit zpx files to same amount of npx files
        #
        target_dir = f"{output}/{date}/2-SHF"
        pix_dirs = set()
        for file in Path().rglob(f"**/*-clean-*.xml"): 
            if file.parent.name == date:  
                #print (f"file: {file}")
                label = re.match("(.*)-clean-",str(file.name)).group(1)
                #print (f"LABEL {label}")
                if label is None:
                    raise TypeError ("label cannot be none")
                npx_fn = f"{target_dir}/{label}-clean.npx.xml"
                s.transform(file, zpx2mpx, npx_fn)

        #
        # STEP 2 Writing single join/pack file
        #
        pack_npx = Path(f"{target_dir}/pack.npx")
        print(f"About to write join to {pack_npx}")

        try:
            first = list(Path().glob(f"{target_dir}/*.npx.xml"))[0]
        except: raise TypeError ("Join failed!")
        
        s.join(first, join_npx, pack_npx)

        #
        # STEP 3 Write csv file
        #

        print (f"About to write csv {pack_npx}")
        Npx2csv (pack_npx, f"{target_dir}/pack")

        #
        # STEP 4 Copy image/attachment files
        # ATTENTION: SLOPPY UPDATE
        print ("Copying images")
        pix_target = Path(target_dir).parent.parent.joinpath("pix")
        for pic in Path().rglob(f"**/pix_*/*"):
            #print (f"****{file.parent.parent.name}")
            if not (file.parent.name == output):
                if not pix_target.exists():
                    pix_target.mkdir(parents=True)
                out = pix_target.joinpath(pic.name)
                if not out.exists():
                    print (f"{pic} -> {out}")
                    shutil.copyfile(pic, out)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Automation for SHF chain")
    parser.add_argument("-d", "--date", required=True, help="Export date you want to pack")
    parser.add_argument("-o", "--output", required=True, help="Target dir for pack files, e.g. HFObjekte")
    args = parser.parse_args()

    Ford(date=args.date, output=args.output)
