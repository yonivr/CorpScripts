#cpu count
$result = @()
$vmhost =  Get-VMHost | ?{$_.ConnectionState -eq "Connected"}
foreach ($esxi in $vmhost) {
    $HostCPU = $esxi.ExtensionData.Summary.Hardware.NumCpuPkgs
    $HostCPUcore = $esxi.ExtensionData.Summary.Hardware.NumCpuCores/$HostCPU
    $obj = new-object psobject
    $obj | Add-Member -MemberType NoteProperty -Name name -Value $esxi.Name
    $obj | Add-Member -MemberType NoteProperty -Name CPUSocket -Value $HostCPU
    $obj | Add-Member -MemberType NoteProperty -Name Corepersocket -Value $HostCPUcore
    $result += $obj
}
$result


#host hardware
Get-VMHost |Sort Name |Get-View |
Select Name, 
@{N=“Type“;E={$_.Hardware.SystemInfo.Vendor+ “ “ + $_.Hardware.SystemInfo.Model}},
@{N=“CPU“;E={“PROC:“ + $_.Hardware.CpuInfo.NumCpuPackages + “ CORES:“ + $_.Hardware.CpuInfo.NumCpuCores + “ MHZ: “ + [math]::round($_.Hardware.CpuInfo.Hz / 1000000, 0)}},
@{N=“MEM“;E={“” + [math]::round($_.Hardware.MemorySize / 1GB, 0) + “ GB“}} | Export-Csv c:\hostinfo.csv
