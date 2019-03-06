resource r0
{
        on nfs1.deposit-solutions.local
        {
                device /dev/drbd0;
#                disk "/dev/md/nfs1:0p1";
                disk "/dev/md0p1";
                address 10.1.2.25:7788;
                meta-disk internal;
        }
        on nfs2.deposit-solutions.local
        {
                device /dev/drbd0;
#                disk "/dev/md/nfs2:0p1";
                disk "/dev/md0p1";
                address 10.1.2.26:7788;
                meta-disk internal;
        }
}


