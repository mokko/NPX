"""
A "conveyor belt" to convert output of MpApi into the SHF exchange format; i.e. the conveyor belt
multiple steps, typically a series of xslt transformations.

Input: scans pwd and looks for {date}/*-clean-*.xml wth the specified date
Writes many output files, typically for every step one

Design Considerations
* This little script is supposed to grow with time and has been doing so since May 2021; perhaps eventually
  we'll use pipeline again.
* We want to send SHF the least amount of packages (files) possible
* Don't overwrite files already written by a previous iteration; if user wants an overwrite, they have to
  delete files manually.
* Number output files by step

#input
sdata/HF-AKu-Module/20210521
sdata/HF-AKu-StuSam/20210521/1.clean-group30356.xml
{DataDir}/{ExhibitOrGroupDir}/{DateDir}/{many *-clean-*.npx.xml files}
sdata/pix_HF-AKu-Module 
sdata/{individual pix dirs}

#target
sdata/SHF/2021521/2-SHF/1.clean-group30356.npx.xml # many npx.xml files
sdata/SHF/2021521/2-SHF/pack.npx # one pack file; duplicates are being weeded out
sdata/SHF/pix/1.jpg #many image files

USAGE
    ford2.py --date 20210524 --output SHF
 
CURRENT STEPS
    (1) convert individual pack.zml files to npx
    (2) bundle everything to a superpack
    (3) fix superpack -> todo
    (4) split in eröffnet, nicht eröffnet, nicht zugeordnet
    (5) write csv for eröffnet.npx
    (6) write html list for eö.npx -> todo
    (7) convert images for freigegebene digital assets of the objects in eröffnet.npx
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

#TODO: still relies on pipeline 
#TODO: config data should go in separate file
saxon_path = "C:/m3/SaxonHE10-5J/saxon-he-10.5.jar"
sys.path.append("C:/m3/Pipeline/src")  
from Saxon import Saxon
from lvlup.Npx2csv import Npx2csv
ImageFile.LOAD_TRUNCATED_IMAGES = True
xslDir = Path(__file__).parent.joinpath("xsl")


class Ford:
    def __init__(self, *, date, output):
        # e.g. Afrika-Ausstellung-clean-exhibit20226.xml
        #print (f"__init__DATE{date}")

        if not Path(output).is_dir():
            print (f"Making dir {output}")
            Path(output).mkdir()
        logfile = Path(output).joinpath("pix.log")
        logging.basicConfig(
            filename=logfile, filemode="w", encoding="utf-8", level=logging.INFO
        )
        self.targetDir = Path(output).joinpath(date) # output should be "SHF"
        #1st: convert packs to individual npx
        self.zpx2npx(date=date, outDir="1-packs") # 
        #2nd: join superpack 
        packNpx = self.joinPack(inDir="1-packs", out="2-superpack.npx.xml")
        #3rd: fix the superpack
        fixFn = self.transform(src=packNpx, xsl="fix.xsl", out="3-fix.npx.xml")
        #4th: split superpack
        self.transform(src=fixFn, xsl="splitPack.xsl", out="4-o.xml")
        #5th: convert eröffnet only to csv
        self.writeCsv(src="eröffnet.npx.xml")
        #6th write htmlList
        self.transform(src="eröffnet.npx.xml", xsl="ListeFreigegebeneDigitalisate.xsl", out="ListeFreigegebeneDigitalisate.html")
        #7th convert and copy freigebene attachments
        self.cpAttachments(output=output)
    
    def transform (self,*, src, xsl, out):
        """
            One transform method for a more unified interface, expects the usual three
            src and out are usually in targetDir
            xsl is in the xslDir
        """
        s = Saxon(saxon_path)
        if type(src) is str:
            srcFn = self.targetDir.joinpath(src)
        else:
            srcFn = src
        xslFn = Path(xslDir).joinpath(xsl)
        outFn = self.targetDir.joinpath(out)
        s.transform(srcFn, xslFn, outFn)
        return outFn
        
    def cpAttachments(self, *, output):
        """
            Copy and resize images and just copy some other attachment files.
            Resizing to longest size 1848 px.
            
            Input files are **/pix_*/*, but only if attachments are in eröffnet.npx.xml
            Output is written to {output}/pix

            Biggest png that I've found so far is 1848.
            3 Wege wants origname with longest side 1848.
        """
        pixDir = self.targetDir.parent.joinpath("pix")
        if not pixDir.exists():
            pixDir.mkdir(parents=True)
        print("Copying images to {pixDir}, if necessary")
        for pic_fn in Path().rglob(f"**/pix_*/*"):
            #print (f"****{pic_fn}")
            if pic_fn.suffix != ".mp3": #pil croaks over mp3
                if self.inEö(fn=pic_fn.name):
                    if not (pic_fn.parent.name == output):
                        try:
                            im = Image.open(pic_fn)
                        except:
                            logging.info(f"{pic_fn} no pic")
                        out_fn = pixDir.joinpath(pic_fn.name)
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
        if not hasattr(self, "eö"):
            eöFn = self.targetDir.joinpath("eröffnet.npx.xml")
            self.eö = etree.parse(str(eöFn))
        r = self.eö.xpath(f"/n:npx/n:multimediaobjekt[n:dateinameNeu= '{fn}']", namespaces={"n": "http://www.mpx.org/npx"})
        #print (r)
        if r:
            return True
        else:   
            return False

    def joinPack(self, *, inDir, out):
        """
            STEP 2 : Writing single pack file from many small npx files.
            
            Looks for many *.npx.xml files in inDir
            Outputs one superpack file.
        """
        s = Saxon(saxon_path)
        outFn = self.targetDir.joinpath(out)
        print(f"About to write superpack to {str(outFn)}")

        try:
            first = list(self.targetDir.glob(f"{inDir}/*.npx.xml"))[0]
        except:
            raise TypeError("Join failed!")

        s.join(first, xslDir.joinpath("join_npx.xsl"), outFn)
        return outFn

    def splitPack (self, *, in_fn, targetDir):
        s = Saxon(saxon_path)
        #print (f"TARGET_DIR: {targetDir}")
        eö_fn = targetDir.joinpath("eröffnet.npx.xml")
        print ("About to SPLIT PACK if necessary")
        if not eö_fn.exists():
            s.transform(in_fn, split_npx, "o.xml")
            #quick and dirty
            shutil.move("eröffnet.npx.xml", targetDir)
            shutil.move("nichtEröffnet.npx.xml", targetDir)
            shutil.move("nichtZugeordnet.npx.xml", targetDir)

    def writeCsv(self, *, src):
        """
            STEP 3 : Write csv file
        """
        fn = self.targetDir.joinpath (src)
        #self.eö = etree.parse(str(fn))

        print(f"About to write csv from {fn}")
        Npx2csv(fn, self.targetDir.joinpath("eö"))

    def zpx2npx (self, *, date, outDir):
        """
            STEP 1 : Convert many small group/exhibit zpx files to same amount of npx files

            Looks for *-clean-*.xml files in ALL subdirs and writes many small 
            *-clean.npx.xml files.
            
            Write in subdir 1-packs
        """
        s = Saxon(saxon_path)
        for file in Path().rglob(f"**/*-clean-*.xml"):
            if file.parent.name == date:
                # print (f"file: {file}")
                label = re.match("(.*)-clean-", str(file.name)).group(1)
                # print (f"LABEL {label}")
                if label is None:
                    raise TypeError("label cannot be none")
                xsl = xslDir.joinpath("zpx2npx.xsl")
                npxFn = self.targetDir.joinpath(outDir, f"{label}-clean.npx.xml")
                s.transform(file, xsl, npxFn)
        
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
    