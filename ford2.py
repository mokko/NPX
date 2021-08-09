"""
Automation for npx/shf. This little script is supposed to grow with time.

We want to send SHF the least amount of packages possible

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
    ford2.py --date 20210524 --output HFObjekte
 
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
split_npx = "C:/m3/zpx2npx/xsl/splitPack.xsl"

ImageFile.LOAD_TRUNCATED_IMAGES = True


class Ford:
    def __init__(self, *, date, output):
        # e.g. Afrika-Ausstellung-clean-exhibit20226.xml
        #print (f"__init__DATE{date}")

        logfile = Path(output).joinpath("pix.log")
        logging.basicConfig(
            filename=logfile, filemode="w", encoding="utf-8", level=logging.INFO
        )

        target_dir = Path(output).joinpath(date).joinpath("2-SHF")

        self.zpx2npx(target_dir=target_dir, date=date)
        pack_npx = self.packNpx(target_dir=target_dir)
        self.splitPack(in_fn=pack_npx, target_dir=target_dir)
        
        eö_fn = target_dir.joinpath ("eröffnet.npx.xml")
        self.eö = etree.parse(str(eö_fn))
        self.writeCsv(target_dir=target_dir, source_npx=eö_fn)
        self.cpAttachments(target_dir=target_dir, output=output)
    
    def cpAttachments(self, *, target_dir, output):
        """
            STEP 4 : Copy image/attachment files
            Resizing to longest size 1500 px
            Biggest png that I've found so far is 1848.
            3 Wege wants origname with longest side 1848.
        """
        print("Copying images, if necessary")
        pix_target = Path(target_dir).parent.parent.joinpath("pix")
        for pic_fn in Path().rglob(f"**/pix_*/*"):
            #print (f"****{pic_fn}")
            if pic_fn.suffix != ".mp3": #pil croaks over mp3
                if self.inEö(fn=pic_fn.name):
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
                            if width > 1848 or height > 1848:
                                logging.info(f"{pic_fn} exceeds size: {width} x {height}")
                                if width > height:
                                    factor = 1848/width
                                else: # height > width or both equal
                                    factor = 1848/height
                                new_size = (int(width*factor), int(height*factor))
                                print (f"*resizing {factor} {new_size}")
                                im = im.convert("RGB")    
                                out = im.resize(new_size, Image.LANCZOS)
                                out.save(out_fn)
                            else:
                                shutil.copyfile(pic_fn, out_fn)
                            # with ZipFile('spam.zip', 'w') as myzip:
                            #    myzip.write('eggs.txt')

    def inEö (self, *, fn):
        """
        Tests if given filename fn is in the set of already opened exhibits (eröffnet).
        Returns True if fn exists, else False.
        """        
        #print (f"***fn {fn}")
        r = self.eö.xpath(f"/n:npx/n:multimediaobjekt[n:dateinameNeu= '{fn}']", namespaces={"n": "http://www.mpx.org/npx"})
        #print (r)
        if r:
            return True
        else:   
            return False

    def packNpx(self, *, target_dir):
        """
            STEP 2 : Writing single pack file from many small npx files.
            
            Looks for many *.npx.xml files in all subdirs
            Outputs one pack.npx file
        """
        s = Saxon(saxon_path)
        pack_npx = Path(target_dir).joinpath("pack.npx")
        print(f"About to write join to {str(pack_npx)}")

        try:
            first = list(Path().glob(f"{target_dir}/*.npx.xml"))[0]
        except:
            raise TypeError("Join failed!")

        s.join(first, join_npx, pack_npx)
        return pack_npx

    def splitPack (self, *, in_fn, target_dir):
        s = Saxon(saxon_path)
        #print (f"TARGET_DIR: {target_dir}")
        eö_fn = target_dir.joinpath("eröffnet.npx.xml")
        print ("About to SPLIT PACK if necessary")
        if not eö_fn.exists():
            s.transform(in_fn, split_npx, "o.xml")
            #quick and dirty
            shutil.move("eröffnet.npx.xml", target_dir)
            shutil.move("nichtEröffnet.npx.xml", target_dir)
            shutil.move("nichtZugeordnet.npx.xml", target_dir)

    def writeCsv(self, *, target_dir, source_npx):
        """
            STEP 3 : Write csv file
        """

        print(f"About to write csv {source_npx}")
        Npx2csv(source_npx, target_dir.joinpath("eö"))

    def zpx2npx (self, *, target_dir, date):
        """
            STEP 1 : Convert many small group/exhibit zpx files to same amount of npx files

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
                npx_fn = target_dir.joinpath(f"{label}-clean.npx.xml")
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
    