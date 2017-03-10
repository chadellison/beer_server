# README

## Description
This Rails API serves the React app, [beer-project](https://beer-project0123.herokuapp.com/#)

Incorporates mailers and uses sendgrid for sending emails in production.
Allows users to filter beers by type, name, and allows users to sort beers by
ABV, rating, and alphabetically. Allows users to add and update beers.
Queries are optimized so that no matter how many filters are applied only one query
is made to the db.

* Ruby version
  2.3

* Rails Version
  5.0.1

### Test Suite
* The test suite can be run with "rspec" from the root directory
