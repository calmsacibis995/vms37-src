$ inquire source "Enter source device"
$ inquire target "Enter target device"
$ inquire scratch "Enter scratch device"
$ inquire restart "Is this a restarted build?"
$ if restart then options := RESTART
$ if .not. restart then options := NONE
$ inquire batch_job "Submit as batch job?"
$ if .not. batch_job then batch := ""
$ 'batch @diskitbld 'source' 'scratch' 'target' 'options' wrkd$:[kits]
