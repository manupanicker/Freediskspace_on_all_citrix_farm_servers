#Written by Manu Panicker manu.panicker@atos.net
$xaservers = Invoke-Command -ComputerName citrixserver1.c1cs1.contoso.com -ScriptBlock {asnp citrix* -ea 0
get-xaserver | Select-Object -ExpandProperty servername}
$fqdn=foreach($xaserver in $xaservers)
{
$xaserver+"."+($xaserver.substring(0,2)+'1cs1.contoso.com')
}
$job=ICM -AsJob -ComputerName $fqdn -ScriptBlock{Get-WmiObject -class win32_logicaldisk | where{$_.deviceid -eq "C:"`
 -or $_.deviceid -eq "D:"}`
|select PSComputerName,deviceid,volumename,@{Label="Total Space(in GB)";Expression={$_.Size / 1gb -as [int] }},`
@{Label="Total Free Space(in GB)";Expression={$_.freespace / 1gb -as [int] }}
}

$getjob=Get-Job -id $job.Id
$jobstate =$getjob.State

while($jobstate -eq "Running"){
for($a=1; $a -lt 100; $a++){ 
Write-Progress -Activity "Working to find freespace on your Citrix servers..." -PercentComplete $a -CurrentOperation "$a Complete" -Status "Please wait."
$getjob=Get-Job -id $job.Id
$jobstate =$getjob.State
}
}
<#$jobs = get-job | ? { $_.state -eq "running" }
$total = $jobs.count
$runningjobs = $jobs.count

   
while($runningjobs -gt 0) {
# Update progress based on how many jobs are done yet.
$percent=[math]::Round((($total-$runningjobs)/$total * 100),2)
write-progress -activity "Starting Provisioning Modules Instances" -status "Progress: $percent%" -percentcomplete (($total-$runningjobs)/$total*100)

# After updating the progress bar, get current job count
$runningjobs = (get-job | ? { $_.state -eq "running" }).Count
}#>

<#
$jobid=$job.id
Wait-Job -Id $jobid#>

$receivejob=receive-job -id $job.Id | sort PSComputerName| select PSComputerName,deviceid,"Total Space(in GB)","Total Free Space(in GB)"
$receivejob | ft PSComputerName,deviceid,"Total Space(in GB)","Total Free Space(in GB)" -AutoSize
Read-Host "Enter Cntrl C to exit"