import subprocess
import parted
import logging

from .utils import *


class sdcard:
    def __init__(self, device: str):
        self._device = device
        self._devname = '/dev/' + device
        self._pd = None
        self._partition_count = 0
        self._disk = None
        self._parts = list()
        self._partition_table = (
            (256, "fat32", "BOOT"),  # BOOT sdx1
            (512, "fat32", "LINUX"),  # LINUX sdx2
            (-1, "ext4", "ROOTFS")  # LINUX sdx3
        )

    def _add_partition(self, size, fs_type, part_name):
        device = self._pd
        disk = self._disk
        self._partition_count += 1
        part_type = parted.PARTITION_NORMAL
        free = disk.getFreeSpaceRegions()[0]
        if (size == -1):
            geometry = parted.Geometry(device, start=free.start, end=free.end)
        else:
            geometry = parted.Geometry(device, start=free.start, length=int(size * 1000 * 1000 / 512))
        fs = parted.FileSystem(type=fs_type, geometry=geometry)
        partition = parted.Partition(disk, type=part_type, geometry=geometry, fs=fs)
        constraint = parted.Constraint(maxGeom=partition.geometry)
        disk.addPartition(partition, constraint)
        logging.info("Created partition: " + part_name)
        self._parts.append([part_name, self._device + str(self._partition_count), fs_type])
        disk.commit()

    def _format_partitions(self):
        for p in self._parts:
            if (p[2] == 'fat32'):
                fmt_cmd = ['/sbin/mkfs.vfat', '-n', p[0], "/dev/" + p[1]]
                print(fmt_cmd)
            elif (p[2] == "ext4"):
                fmt_cmd = ['/sbin/mkfs.ext4', '-q', '-L', p[0], "/dev/" + p[1]]
                print(fmt_cmd)
            else:
                fmt_cmd = ""
            pipe = subprocess.Popen(fmt_cmd, stdout=subprocess.PIPE)
            out, err = pipe.communicate()
            logging.info("Formatted " + p[0] + " with " + p[2])

    def make_partitions(self):
        if not is_sd(self._device):
            logging.info("error: %s is not and sd device" % self._device)
            return
        part_table = self._partition_table
        umount_sd(self._device)
        self._pd = parted.getDevice(self._devname)
        self._disk = parted.freshDisk(self._pd, parted.diskType["msdos"])
        for p in part_table:
            self._add_partition(*p)
        cmd = ['/sbin/partprobe', '/dev/' + self._devname]
        pipe = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = pipe.communicate()
        self._format_partitions()