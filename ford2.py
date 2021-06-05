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
 
TODO: Let's write final version to HF-Export network share to disk space on laptop!
 
"""

import argparse
import logging
import os
import re
import shutil
import sys
from PIL import Image, ImageFile
from pathlib import Path
from lxml import etree

# adir = Path(__file__).parent
sys.path.append("C:/m3/Pipeline/src")  # what the heck?
from Saxon import Saxon
from lvlup.Npx2csv import Npx2csv

saxon_path = "C:/m3/SaxonHE10-5J/saxon-he-10.5.jar"
zpx2mpx = "C:/m3/zpx2npx/xsl/zpx2npx.xsl"
join_npx = "C:/m3/zpx2npx/xsl/join_npx.xsl"

ImageFile.LOAD_TRUNCATED_IMAGES = True


class Ford:
    def __init__(self, *, date, output):
        # e.g. Afrika-Ausstellung-clean-exhibit20226.xml
        #print (f"__init__DATE{date}")

        logfile = Path(output).joinpath("pix.log")
        logging.basicConfig(
            filename=logfile, filemode="w", encoding="utf-8", level=logging.INFO
        )

        target_dir = f"{output}/{date}/2-SHF"

        self.zpx2npx(target_dir=target_dir, date=date)
        pack_npx = self.packNpx(target_dir=target_dir)
        self.writeCsv(target_dir=target_dir, pack_npx=pack_npx)
        self.cpAttachments(target_dir=target_dir, output=output)
    
    def cpAttachments(self, *, target_dir, output):
        """
            STEP 4 Copy image/attachment files
            Resizing to longest size 1500 px
        """
        print("Copying images")
        pix_target = Path(target_dir).parent.parent.joinpath("pix")
        for pic_fn in Path().rglob(f"**/pix_*/*"):
            # print (f"****{file.parent.parent.name}")
            if not (pic_fn.parent.name == output):
                try:
                    im = Image.open(pic_fn)
                except:
                    logging.info(f"{pic_fn} no pic")
                if not pix_target.exists():
                    pix_target.mkdir(parents=True)
                out_fn = pix_target.joinpath(pic_fn.name)
                if not out_fn.exists():
                    print(f"{pic_fn} -> {out_fn}")
                    width, height = im.size
                    if width > 1500 or height > 1500:
                        logging.info(f"{pic_fn} exceeds size: {width} x {height}")
                        if width > height:
                            factor = 1500/width
                        else: # height > width or both equal
                            factor = 1500/height
                        new_size = (int(width*factor), int(height*factor))
                        print (f"*resizing {factor} {new_size}")
                        im = im.convert("RGB")    
                        out = im.resize(new_size, Image.LANCZOS)
                        out.save(out_fn)
                    else:
                        shutil.copyfile(pic_fn, out_fn)
                    # with ZipFile('spam.zip', 'w') as myzip:
                    #    myzip.write('eggs.txt')

    def packNpx(self, *, target_dir):
        """
            STEP 2 
            
            Writing single pack file from many small npx files.
            
            Looks for many *.npx.xml files in all subdirs
            Outputs one pack.npx file
        """
        s = Saxon(saxon_path)
        pack_npx = Path(f"{target_dir}/pack.npx")
        print(f"About to write join to {pack_npx}")

        try:
            first = list(Path().glob(f"{target_dir}/*.npx.xml"))[0]
        except:
            raise TypeError("Join failed!")

        s.join(first, join_npx, pack_npx)
        return pack_npx

    def writeCsv(self, *, target_dir, pack_npx):
        """
            STEP 3 Write csv file
        """

        print(f"About to write csv {pack_npx}")
        Npx2csv(pack_npx, f"{target_dir}/pack")

    def zpx2npx (self, *, target_dir, date):
        """
            STEP 1 
            Convert many small group/exhibit zpx files to same amount of npx files

            Looks for *-clean-*.xml files in ALL subdirs and writes many small 
            *-clean.npx.xml files.
        """
        s = Saxon(saxon_path)
        pix_dirs = set()
        for file in Path().rglob(f"**/*-clean-*.xml"):
            if file.parent.name == date:
                # print (f"file: {file}")
                label = re.match("(.*)-clean-", str(file.name)).group(1)
                # print (f"LABEL {label}")
                if label is None:
                    raise TypeError("label cannot be none")
                npx_fn = f"{target_dir}/{label}-clean.npx.xml"
                s.transform(file, zpx2mpx, npx_fn)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Automation for SHF chain")
    parser.add_argument(
        "-d", "--date", required=True, help="Export date you want to pack"
    )
    parser.add_argument(
        "-o",
        "--output",
        required=True,
        help="Target dir for pack files, e.g. HFObjekte",
    )
    args = parser.parse_args()

    Ford(date=args.date, output=args.output)
