import sys

with open(sys.argv[1],'r') as bf:
    with open(sys.argv[2],'w') as outfile:
        for line in bf:
            for char in line:
                outfile.write(bin(ord(char))[2:].zfill(8)+' -- '+char+'\n')
