---
title: Shrinking a Google Compute disk
date: 2019-10-27 20:35:17 +0800 
tags:
 - google compute
 - OS
 - unix
licence: Copyright © 2019 Ray. <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Attribution 4.0 International License" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>
---

Problem: How to shrink a disk (partitionless) as well as the filesystem on it?

Situation: We have a disk that is much larger than what we need. Specifically, we had a 200 GB regional standard
persistent disk on Google Compute, but we only needed a fraction of that. In addition, we cannot resize the disk itself,
because regional standard persistent disks have a 200-GB minimum. [^200-GB-min]

Solution: Shrink the filesystem with `resize2fs -M` (here `/dev/sdc`) so that it can fit on the new smaller disk (here
`/dev/sdd`), than use `partclone.[fstype] -b` to copy to a new disk.

- However,

  - before we can run `resize2fs`, we need to run `e2fsck` first.

    ```console
    ray@instance-1:/tmp$ sudo e2fsck -f /dev/sdc
    e2fsck 1.44.5 (15-Dec-2018)
    Pass 1: Checking inodes, blocks, and sizes
    Pass 2: Checking directory structure
    Pass 3: Checking directory connectivity
    Pass 4: Checking reference counts
    Pass 5: Checking group summary information
    /dev/sdc: 434/434176 files (0.7% non-contiguous), 1257420/1732511 blocks
    ```

- Now, we can run `resize2fs`. The `-M` option tells it to shrink the filesystem to the minimum size. [^resize2fs]

  ```console
  ray@instance-1:/tmp$ sudo resize2fs -M /dev/sdc
  resize2fs 1.44.5 (15-Dec-2018)
  Resizing the filesystem on /dev/sdc to 1732504 (4k) blocks.
  The filesystem on /dev/sdc is now 1732504 (4k) blocks long.
  ```

- Clone the filesystem to a new disk. We can use `partclone.[fstype]`. In our case, we are using `partclone.ext4`. We
  specify the `-b` to select the device-to-device cloning mode. [^partclone]

  ```console
  ray@instance-1:/tmp$ sudo partclone.ext4 -b -s /dev/sdc -o /dev/sdd
  Partclone v0.3.11 http://partclone.org
  Starting to back up device(/dev/sdc) to device(/dev/sdd)
  Elapsed: 00:00:01, Remaining: 00:00:00, Completed: 100.00%                      
  Total Time: 00:00:01, 100.00% completed!
  done!
  File system:  EXTFS
  Device size:    7.1 GB = 1732504 Blocks
  Space in use:   5.2 GB = 1257420 Blocks
  Free Space:     1.9 GB = 475084 Blocks
  Block size:   4096 Byte
  Elapsed: 00:02:16, Remaining: 00:00:00, Completed: 100.00%, Rate:   2.27GB/min, 
  current block:    1606658, total block:    1732504, Complete: 100.00%           
  Total Time: 00:02:16, Ave. Rate:    2.3GB/min, 100.00% completed!
  Syncing... OK!
  Partclone successfully cloned the device (/dev/sdc) to the device (/dev/sdd)
  Cloned successfully.
  ```
  
  - Based on the examples section of partclone, one might think we can just use `-c` for cloning (which fails). You
    might then try to overcome the error by forcing the output with `-O` instead of just `-o` (which also fails). Same
    with throwing in a `-b` option since both are devices. This won't work because `-c` writes to the output a "special
    image format".

- We had to shrink the filesystem to fit the new smaller disk. It might be the case that the filesystem is not taking up
  the entire capacity of the new disk. To resize the filesystem to fit the entirety of the new disk, just run `resize2fs`
  without any options on the disk: `sudo resize2fs /dev/sdd`. 

[^200-GB-min]: <https://cloud.google.com/compute/docs/disks/#limits_2>
[^resize2fs]: <https://linux.die.net/man/8/resize2fs>
[^partclone]: <https://manpages.debian.org/testing/partclone/partclone.8.en.html>
