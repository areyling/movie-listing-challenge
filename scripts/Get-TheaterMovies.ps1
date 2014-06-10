$rtBaseUrl = 'http://api.rottentomatoes.com/api/public/v1.0'
$moviesUrlFmt = $rtBaseUrl + '/lists/movies/in_theaters.json?apikey={0}&page={1}&page_limit={2}'

function Get-TheaterMovies {
[CmdletBinding()]
param (
  [Parameter(Position=0, Mandatory=$true)]
  [ValidateNotNullOrEmpty()]
  [Alias('k','s')]
  [string] $apiKey,

  [Parameter(Mandatory=$false)]
  [ValidateScript({ $_ -ge 1 })]
  [Alias('p')]
  [int] $page = 1,

  [Parameter(Mandatory=$false)]
  [ValidateScript({ $_ -ge 1 })]
  [Alias('l','limit')]
  [int] $pageLimit = 16
)

  try {
    $url = $moviesUrlFmt -f $apiKey,$page,$pageLimit
    $response = Invoke-RestMethod $url

    $remainder = $response.total % $pageLimit
    $totalPages = ($response.total - $remainder)/$pageLimit + 1
    $response | Add-Member -MemberType NoteProperty -Name pages -Value $totalPages -PassThru
  } catch [System.Net.WebException],[System.IO.IOException] {
    $record = $error[0]
    $err = New-Object PSObject -Property @{
      Message = "Unable to get listing of movies in theaters: $($record.Exception.Message)"
      Exception = $record.Exception
      Detail = $record.ErrorDetails.Message
      Url = $url
    }
    return $err
  }
}