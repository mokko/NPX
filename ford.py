"""
Automation for npx.

This little script is supposed to grow with time.

Execute it in the project date directory
e.g. HFObjekte/20210523
"""

import argparse
import os
import re
import sys
from pathlib import Path
from lxml import etree
#adir = Path(__file__).parent
sys.path.append("C:/m3/Pipeline/src")  # what the heck?
from Saxon import Saxon
from lvlup.Npx2csv import Npx2csv

saxon_path = "C:/m3/SaxonHE10-5J/saxon-he-10.5.jar"
zpx2mpx = "C:/m3/zpx2npx/zpx2npx.xsl"
join_npx = "C:/m3/zpx2npx/xsl/join_npx.xsl"

class Ford:
    def __init__(self):
        #e.g. Afrika-Ausstellung-clean-exhibit20226.xml
        s = Saxon(saxon_path)
        for file in Path().glob('*-clean-*.xml'):
            label = re.match("(.*)-clean-",str(file)).group(1)
            npx_fn = f"2-SHF/{label}-clean.npx.xml"
            s.transform(file, zpx2mpx, npx_fn)

        label = str(Path().resolve().parent.name)
        date = str(Path().resolve().name)
        pack_npx = Path(f"2-SHF/{label}{date}.npx")
        print(f"About to write join to {pack_npx}")

        first = list(Path().glob('2-SHF/*.npx.xml'))[0]
        s.join(first, join_npx, pack_npx)

        print (f"About to write csv {pack_npx}")
        Npx2csv (pack_npx, f"2-SHF/{label}{date}")

    def join_npx(self, *, inL):
        """
        Obsolete: LXML join does not weed out duplicates (records with same ids), so 
        use the xslt version instead.
        """
        ETparser = etree.XMLParser(remove_blank_text=True)
        NSMAP = {"n":"http://www.mpx.org/npx"}
        firstET = None
        for file in inL:
            print(f"joining {file}")
            ET = etree.parse(str(file), ETparser)
            if firstET is None:
                firstET = ET
            else:
                #ordered as in source files: sammlungobjekt, mm, sammlungobjekt ...
                itemsL = ET.xpath("/n:npx/n:*", namespaces=NSMAP)
                rootN = firstET.xpath("/n:npx",namespaces=NSMAP)[0]
                if len(itemsL) > 0:
                    for newItemN in itemsL:
                        rootN.append(newItemN)
                        print(newItemN)
        return firstET
        
    def ETtoFile(self, *, ET, path):
        #tree = etree.ElementTree(ET)
        #currently without unicode declaration
        ET.write(
            str(path), pretty_print=True, encoding="UTF-8"
        ) 

if __name__ == "__main__":
    Ford()
