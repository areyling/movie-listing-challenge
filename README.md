Movie listing challenge
=======================

Lists movies currently in theaters, and finds the average age of the cast.

## Usage

#### What you need

* PowerShell v3 or later (developed and tested with v4)
* a valid Rotten Tomatoes API key ([register](http://developer.rottentomatoes.com/member/register))
* a valid TMDb API key ([register](https://www.themoviedb.org/account/signup), then go to
the API section under your [account info](https://www.themoviedb.org/account))

#### Running

1. Copy the included `config.example.json` file from the repo root to the same
directory and name it `config.json`. 
2. Edit `config.json`, replacing `YOUR_ROTTEN_TOMATOES_API_KEY` and `YOUR_TMDB_API_KEY` with
your valid API keys.
3. Run `movies.bat`. Alternatively, you can run the `movies.ps1` script directly.

## Development

#### Resources

* [Rotten Tomatoes API docs](http://developer.rottentomatoes.com/docs)
* [TMDb API docs](http://docs.themoviedb.apiary.io/)