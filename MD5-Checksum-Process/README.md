MD5-Checksum-Process
====================

A bash script to generate MD5 checksums and a PHP script to distill that data.

### MySQL Import

Column names for MySQL import.

    directory_name,check_date,check_time,md5_value,file_size,file_name,directory_path,modified_date,modified_time,changed_date,changed_time

### Concatenate Individual CSV Files Into One Large File

How to concatenate individual CSV files into one large file.

    find /Users/jack/Desktop/CS-Files-From-Something -name "*.csv" | xargs -n 1 tail -n +2 > ~/Desktop/CS-Files-From-Something.csv