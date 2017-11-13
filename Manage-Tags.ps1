#Create Tag
New-TagCategory -Name <name> -Cardinality "Single" -EntityType "VirtualMachine"
New-Tag -Name <name>  -Category <name>  -Description "description"
#Assign Tag
get-vm <name> | New-TagAssignment -Tag $TagDev
#Report by tag
Get-VM <Name of VM> | Select Name,@{N="Tags";E={((Get-TagAssignment -Entity $_ | select -ExpandProperty Tag).Name -join ",")}}
