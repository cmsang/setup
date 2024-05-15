sudo parted /dev/sda print
sudo parted /dev/sda
# (parted) resizepart 2 100%
# (parted) quit
sudo resize2fs /dev/sda2
