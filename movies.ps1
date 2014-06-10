[CmdletBinding()]
param ()

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

#load and perform some simple validation on config
function Load-Config($path) {
  if(Test-Path $path) {
    $config = ConvertFrom-Json (Get-Content $path -raw)
    if($config -and -not ([string]::IsNullOrEmpty($config.rottenTomatoesKey) -or [string]::IsNullOrEmpty($config.tmdbKey))) {
      return $config
    }
  }
  return $null
}
$config = Load-Config (Join-Path $scriptPath 'config.json')
if(-not $config) { throw 'Invalid config! Please see the README for details on how to set up these scripts.'; return; }
Write-Verbose "config: $($config)"