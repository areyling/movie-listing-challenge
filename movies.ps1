[CmdletBinding()]
param (
  [switch] $passThru
)

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

#load our helper scripts
$helpersPath = Join-Path $scriptPath 'scripts'
Write-Verbose "loading helper scripts from: $helpersPath"
if(-not (Test-Path $helpersPath)) { throw 'helpers not found!'; return; }
Get-ChildItem $helpersPath -include *.ps1 -recurse | %{
  Write-Verbose " .. loading $($_.FullName)"
  . $_.FullName
}

$result = Get-TheaterMovies $config.rottenTomatoesKey -fullCast $config.fullCast -limit $config.pageSize
if($result.Error) {
  $err = $result.Error
  Write-Error -Exception $err.Exception -Message $err.Message -TargetObject $result
  return
}

$result.movies | %{
  $movie = $_

  $numCastMembers = 0
  $totalAge = 0
  Write-Verbose "getting cast info for: $($movie.title)"
  $castInfo = $movie.cast | %{
    Write-Verbose " .. cast member: $($_.name)"
    $person = Get-CastMemberInfo $config.tmdbKey -name $_.name
    if($person.Error) {
      $target = New-Object PSObject -Property @{OriginalMember=$_; Error=$person.Error}
      Write-Error -Exception $err.Exception -Message $err.Message -TargetObject $target
    } else {
      if($person.ageDays) {
        $totalAge += $person.ageDays
        $numCastMembers++
      }
      $person
    }
  }
  $movie | Add-Member -MemberType NoteProperty -Name castInfo -Value $castInfo

  $ageDaysAvg = [int][Math]::Round($totalAge/$numCastMembers)
  $ageAvg = New-Object DateTime -ArgumentList (New-TimeSpan -Days $ageDaysAvg).Ticks
  $movie | Add-Member -MemberType NoteProperty -Name AverageCastAge -Value ($ageAvg.Year - 1)

  if($passThru.IsPresent) {
    $movie
  } else {
    #format a summary of the movie and its cast
    '{0} ({1}, {2} min., average age {3})' -f $movie.title,$movie.mpaa_rating,$movie.runtime,$movie.AverageCastAge
    $movie.castInfo | Sort name | %{
      if($_.age -gt 0) {
        '   {0} is {1} years old.' -f $_.name,$_.age,$_.birthday
      } else {
        '   {0} (age unknown).' -f $_.name
      }
    }
    '' #add a single line of spacing in between movies
  }
}
