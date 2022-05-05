import subprocess

def find_sd() -> dict:
    sdcards = dict()
    p = subprocess.Popen(["lsblk","-b","--output","TYPE,KNAME,RM,SIZE,PKNAME,MODEL,MOUNTPOINT"],
                       stdout=subprocess.PIPE,shell=False)
    out, err = p.communicate()
    lines=out.decode('utf-8').rsplit("\n")
    for l in lines[1:-1]:
        col = l.split()
        TYPE, KNAME, RM, SIZE  = col[:4]
        size = float(SIZE)/1E9
        if TYPE == "disk" and RM == "1" and \
                15 < size < 130:
            sdcards[KNAME]={ 'size': size, 'model': col[4], 'part' : dict() }
        if TYPE == 'part' and col[4] in sdcards:
            mp = None
            if len(col) == 6:
                mp = col[5]
            sdcards[col[4]]["part"][KNAME] = mp

    return sdcards

def umount_sd(name: str):
    sd = find_sd()
    if name in sd:
        part = sd[name]['part']
        for p in part:
            mountpoint = part[p]
            p=subprocess.Popen(["umount", mountpoint],
                       stdout=subprocess.PIPE,shell=False)
            out, err = p.communicate()

def device_list():
    result = ""
    sd = find_sd()
    sdlist = list()
    for name in sd:
        sdlist.append('/dev/' + name)
    if len(sdlist) > 0:
        result = ','.join(sdlist)
    return result

