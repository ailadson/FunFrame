# FunFrame

A lightweight web server app framework. Its primary purpose was to help me excercise my knowledge, so if you find this, don't use it for production :-D

## Features

* Rack Compliant
* MVC Pattern
* Custom Object-Relational Mapping Implementation (ActiveRecord clone)
* CSFR Protection
* HTML Templating (ERB)
* Compatible with Postgres Databases
* Heroku Compatible

## Getting Started

* Create new project - `ruby path/to/FunFrame/new.rb path/to/[project]`

* Database Setup
  - Edit `db/init.sql`
  - run `db/create.rb`

* Deploy to Heroku
  - `cd path/to/project`
  - `git init`
  - `heroku create`
  - `git add -A`
  - `git commit -m 'first commit`
  - `git push heroku master`
  - `heroku open`

## Example Application

* [Color Songs](https://desolate-everglades-94078.herokuapp.com/)
  * react, postgres, puma, heroku
  * Needs a style and ux reiteration. that'll come soon


## Improvements aka Coming Soon

* Programmatic Migration System for Better Database Management
* Pretty + Useful Error Page
* Compatible with SQLite3
* Prefetching

