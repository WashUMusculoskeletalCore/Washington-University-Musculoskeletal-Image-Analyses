$ SET FILE/ATTRIBUTEs=RFM=STM
$! Original code created by Dan Leib
$ cd dk0:[MICROCT.DATA.00000579.00024797]
$ ipl
/isq_to_aim in C0024404.isq 0 -1
/todicom_from_aim in 00024797.dcm true false
q
$ cd dk0:[MICROCT.DATA.00000579.00024798]
$ ipl
/isq_to_aim in C0024405.isq 0 -1
/todicom_from_aim in 00024798.dcm true false
q
$ cd dk0:[MICROCT.DATA.00000579.00024799]
$ ipl
/isq_to_aim in C0024406.isq 0 -1
/todicom_from_aim in 00024799.dcm true false
q
$ EXIT
