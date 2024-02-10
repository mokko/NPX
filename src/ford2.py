"""
A "conveyor belt" to convert output of MpApi into the SHF exchange format; 
that is a simple chain of steps that are strung one after the other, typically 
a series of xslt transformations.

Input: scans pwd and looks for {date}/*-clean-*.xml wth the specified date
Writes many output files, typically one for every step 

Design Considerations
* This little script is supposed to grow with time and has been doing so since May 2021; 
  perhaps eventually we'll use pipeline again.
* We want to send SHF the least amount of packages (files) possible
* Don't overwrite files already written by a previous iteration; if user wants an 
  overwrite, they have to delete files manually.
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
    cd MpApi/sdata
    ford2.py --date 20210524 --output SHF
 
CURRENT STEPS
    (1) convert individual pack.zml files to npx
    (2) bundle everything to a superpack
    (3) fix superpack -> todo
    (4) split in eröffnet, nicht eröffnet, nicht zugeordnet (optional, only when using --split)
    (5) write csv for eröffnet.npx
    (6) write html list for eö.npx
    (7) convert images for freigegebene digital assets of the objects in eröffnet.npx

RECENT CHANGES
 Use new output dir in C:\m3\zpx2npx\sdata -> still cd to MpApi\sdata dir to execute!
 
Todo
 improve logging
"""

import argparse
import logging
import os
import re
import shutil
import sys
from PIL import Image, ImageFile
from PIL.ExifTags import TAGS
from pathlib import Path
from lxml import etree

# TODO: still relies on pipeline
# TODO: config data should go in separate file
saxon_path = "C:/m3/SaxonHE10-5J/saxon-he-10.5.jar"
sys.path.append("C:/m3/Pipeline/src")
from Saxon import Saxon
from lvlup.Npx2csv import Npx2csv

ImageFile.LOAD_TRUNCATED_IMAGES = True  # does this do anything?
xslDir = Path(__file__).parent.parent.joinpath("xsl")
outDir = Path(__file__).parent.parent.joinpath("sdata")

MAX_SIZE = 4000


class Ford:
    def __init__(self, *, date, output, split):
        # e.g. Afrika-Ausstellung-clean-exhibit20226.xml
        # print (f"__init__DATE{date}")

        self.targetDir = outDir.joinpath(output).joinpath(date)
        print(f"Using {self.targetDir}")
        if not Path(self.targetDir).is_dir():
            print(f"Making dir {self.targetDir}")
            self.targetDir.mkdir(parents=True)

        logfile = self.targetDir.joinpath("pix.log")
        logging.basicConfig(
            filename=logfile, filemode="w", encoding="utf-8", level=logging.DEBUG
        )

        # 1st: convert packs to individual npx
        self.zpx2npx(date=date, outDir="1-packs")  #
        # 2nd: join superpack
        packNpx = self.joinPack(inDir="1-packs", out="2-superpack.npx.xml")

        # 3rd: fix the superpack
        fixFn = self.transform(src=packNpx, xsl="fix.xsl", out="3-fix.npx.xml")

        # 5th: convert eröffnet only to csv
        self.writeCsv(src=fixFn)

        # 6th write htmlList
        self.transform(
            src="3-fix.npx.xml",
            xsl="ListeFreigegebeneDigitalisate.xsl",
            out="6-ListeFreigegebeneDigitalisate.html",
        )

        # 7th convert and copy freigebene attachments from eröffnet.npx
        self.cpAttachments(output=output, path=fixFn)

    def transform(self, *, src, xsl, out):
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

    def cpAttachments(self, *, output, path):
        """
        Copy and resize images or if other file type: just copy  other attachment
        files. Resizing to longest size 1848 px.

        Input files are **/pix_*/*, but _only_ if attachments are in
        eröffnet.npx.xml. Output is written to {output}/pix
        """
        print(f"Enter cpAttachments ...")
        self.pixDir = self.targetDir.parent.joinpath("pix")
        if not self.pixDir.exists():
            self.pixDir.mkdir(parents=True)
        print(f" Copying and resizing images to {self.pixDir}, if necessary")
        for pic_fn in Path().rglob(f"**/pix_*/*"):
            # ignore mp3s b/c pil dies over mp3
            if pic_fn.suffix != ".mp3":
                # converting tif to jpg; do this early to be able to check if in npx
                if pic_fn.suffix.lower().startswith(".tif"):
                    tif_fn = pic_fn
                    jpg_fn = pic_fn.with_suffix(".jpg")
                    if self.inNpx(fn=jpg_fn.name, path=path):
                        # print (f"{pic_fn}")
                        if not (pic_fn.parent.name == output):
                            self.changeOrCopy(pic_fn=tif_fn)
                else:
                    # only act for pic-files in the npx
                    if self.inNpx(fn=pic_fn.name, path=path):
                        # print (f"{pic_fn}")
                        if not (pic_fn.parent.name == output):
                            self.changeOrCopy(pic_fn=pic_fn)

    def inNpx(self, *, fn, path):
        """
        Tests if a given filename fn is referenced in the npx file located at
        path. Returns True if fn exists as n:dateinameNeu, else False.
        """
        if not hasattr(self, "FileCheck"):
            self.FileCheck = etree.parse(str(path))
        r = self.FileCheck.xpath(
            f"/n:npx/n:multimediaobjekt[n:dateinameNeu= '{fn}']",
            namespaces={"n": "http://www.mpx.org/npx"},
        )
        # print (r)
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
        print("Enter joinPack...")
        s = Saxon(saxon_path)
        outFn = self.targetDir.joinpath(out)
        print(f"About to write superpack to {str(outFn)}")

        try:
            first = list(self.targetDir.glob(f"{inDir}/*.npx.xml"))[0]
        except:
            raise TypeError("Join failed!")

        s.join(first, xslDir.joinpath("join_npx.xsl"), outFn)
        return outFn

    def changeOrCopy(self, *, pic_fn):
        """
        This method receives the path to an image file and tries to do the right thing:
        - just copy original image file OR
        - resize to fit limitations OR/AND
        - change format from jpg to tif
        - error

        Expects:
        -pic_fn: path to file

        Usually a jpg, but can also be a tif
        """
        print(f"{pic_fn}")
        CHANGE = False
        try:
            im = Image.open(pic_fn)
        except:
            logging.error(f"{pic_fn} not found or not pic")
        else:  # if no error
            im = im.convert("RGB")
            # new target destination
            out_fn = self.pixDir.joinpath(pic_fn.name)

            if out_fn.suffix.lower().startswith(".tif"):
                out_fn = out_fn.with_suffix(".jpg")
                CHANGE = True
                # print (f"!!!!!{pic_fn} changing format to jpg")
                logging.warning(f"{pic_fn}: from tif to jpg")

            # dont overwrite existing files
            if not out_fn.exists():
                orientation = None
                for key, value in im.getexif().items():
                    if TAGS.get(key) == "Orientation":
                        orientation = value
                        if orientation != 1:
                            CHANGE = True
                            logging.warning(f"{pic_fn}: Orientation {orientation}")
                            print(f"*changing ORIENTATION: {orientation}")
                            if orientation == 3:
                                im = im.rotate(180, expand=True, resample=Image.BICUBIC)
                            if orientation == 6:
                                im = im.rotate(270, expand=True, resample=Image.BICUBIC)
                            if orientation == 8:
                                im = im.rotate(90, expand=True, resample=Image.BICUBIC)

                width, height = im.size
                if width > MAX_SIZE or height > MAX_SIZE:
                    logging.info(f"{pic_fn} exceeds size: {width} x {height}")
                    if width > height:
                        factor = MAX_SIZE / width
                    else:  # height > width or both equal
                        factor = MAX_SIZE / height
                    new_size = (int(width * factor), int(height * factor))
                    print(f"*resizing {factor} {new_size}")
                    im = im.resize(new_size, Image.LANCZOS)
                    CHANGE = True

                if CHANGE:
                    im.save(out_fn)
                else:
                    # print (f"\tjust copying")
                    shutil.copyfile(pic_fn, out_fn)
            # else:
            #    print ("\texists already at target")# {out_fn}

    def writeCsv(self, *, src):
        """
        STEP 3 : Write csv file
        """
        fn = self.targetDir.joinpath(src)
        # self.FileCheck = etree.parse(str(fn))

        print(f"About to write csv from {fn}")
        Npx2csv(fn, self.targetDir.joinpath("5-eö"))

    def zpx2npx(self, *, date, outDir):
        """
        STEP 1 : Convert many small group/exhibit zpx files to same amount of npx files

        Looks for *-clean-*.xml files in ALL subdirs and writes many small
        *-clean.npx.xml files.

        Write in subdir 1-packs
        """
        print("Enter zpx2npx ...")
        s = Saxon(saxon_path)
        for file in Path().rglob(f"**/*-join-*.xml"):
            if file.parent.name == date:
                # print (f"file: {file}")
                label = re.match("(.*)-join-", str(file.name)).group(1)
                # print (f"LABEL {label}")
                if label is None:
                    raise ValueError("label cannot be none")
                print(f"{file}")
                xsl = xslDir.joinpath("zpx2npx.xsl")
                npxFn = self.targetDir.joinpath(outDir, f"{label}-clean.npx.xml")
                s.transform(file, xsl, npxFn)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Automation for SHF chain")
    parser.add_argument(
        "-d", "--date", required=True, help="Export date you want to pack"
    )
    parser.add_argument(
        "-s", "--split", help="Add split eröffnet or not", action="store_true"
    )
    parser.add_argument(
        "-o",
        "--output",
        required=True,
        help="Target dir for pack files, e.g. HFObjekte",
    )
    args = parser.parse_args()

    Ford(date=args.date, output=args.output, split=args.split)
